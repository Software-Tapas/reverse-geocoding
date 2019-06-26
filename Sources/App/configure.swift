import PostgreSQL
import Redis
import Vapor
import Service

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(PostgreSQLProvider())
    try services.register(RedisProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig()
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    middlewares.use(corsMiddleware)
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)

    services.register(DatabaseCachable.self, factory: InMemoryCachingLayerService.makeService)

    if env != .testing {
        // Configuration of PostgreSQL
        let postgreSQLConfig = try PostgreSQLDatabaseConfig(env: Environment.self)
        let postgresql = PostgreSQLDatabase(config: postgreSQLConfig)

        // Configuration of Redis
        let redisConfig = try RedisClientConfig(env: Environment.self)
        let redis = try RedisDatabase(config: redisConfig)

        /// Register the configured PostgreSQL database to the database config.
        var databases = DatabasesConfig()
        databases.enableLogging(on: .psql)
        databases.add(database: postgresql, as: .psql)
        databases.add(database: redis, as: .redis)
        services.register(databases)
        services.register(DatabaseFetchable.self, factory: PostgreSQLDatabaseService.makeService)
        services.register(DatabaseCachable.self, factory: RedisCacheLayerService.makeService)
    }

    var commandConfig = CommandConfig.default()
    commandConfig.use(PurgeRedisCache(), as: "purge-cache")
    services.register(commandConfig)
}

enum AppError: Error {
    case parameterMissing
}

extension RedisClientConfig {
    init(env: Environment.Type) throws {
        guard let urlString = env.get("REDIS_URL"),
            let url = URL(string: urlString)
            else {
                throw AppError.parameterMissing
        }
        self.init(url: url)
    }
}

extension PostgreSQLDatabaseConfig {
    init(env: Environment.Type, transport: PostgreSQLConnection.TransportConfig = .cleartext) throws {
        guard let hostname = env.get("DB_HOST"),
            let portString = env.get("DB_PORT"),
            let username = env.get("DB_USERNAME"),
            let database = env.get("DB_DATABASE"),
            let port = Int(portString)
            else { throw AppError.parameterMissing }
        var password: String?
        if let passwordFile = env.get("DB_PASSWORD_FILE") {
            let url = URL(fileURLWithPath: passwordFile)
            password = try String(contentsOf: url).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else if let passwordFile = env.get("DB_PASSWORD") {
            password = passwordFile
        }
        self.init(hostname: hostname, port: port, username: username, database: database, password: password, transport: transport)
    }
}
