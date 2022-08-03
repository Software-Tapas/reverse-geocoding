import Fluent
import FluentPostgresDriver
import Vapor
import Redis

// configures your application
public func configure(_ app: Application) throws {
    // Register CORS middleware
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    app.middleware.use(CORSMiddleware(configuration: corsConfiguration))
    
    // Setup Redis and PostgreSQL configuration if environment is not in testing mode
    if app.environment != Environment.testing {
        app.redis.configuration = try RedisConfiguration(env: Environment.self)
        app.databases.use(try .postgres(fromEnvironment: Environment.self, app: app), as: .psql)
    }
    
    // Register a command to purge the Redis cache
    app.commands.use(PurgeRedisCacheCommand(), as: "purge-cache")
    try routes(app)
}

enum AppError: Error {
    case environemntParameterMissing
}

extension RedisConfiguration {
    init(env: Environment.Type) throws {
        guard let urlString = env.get("REDIS_URL"),
              let url = URL(string: urlString)
        else {
            throw AppError.environemntParameterMissing
        }
        try self.init(url: url)
    }
}

extension DatabaseConfigurationFactory {
    static func postgres(fromEnvironment env: Environment.Type, app: Application) throws -> DatabaseConfigurationFactory {
        guard let hostname = env.get("DB_HOST"),
              let username = env.get("DB_USERNAME"),
              let database = env.get("DB_DATABASE")
        else { throw AppError.environemntParameterMissing }
        
        // Load password from file, but if it doesn't exsti, try the environment variable.
        // Passing a password via file is recommended.
        guard let password = try Environment.secret(key: "DB_PASSWORD_FILE", fileIO: app.fileio, on: app.eventLoopGroup.next()).wait() ?? Environment.get("DB_PASSWORD") else { throw AppError.environemntParameterMissing }
        
        return .postgres(
            hostname: hostname,
            port: Environment.get("DB_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
            username: username,
            password: password,
            database: database)
    }
}
