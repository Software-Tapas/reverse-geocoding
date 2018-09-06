import PostgreSQL
import Vapor
import Service

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(PostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    if env != .testing {
        // Configuration of PostgreSQL
        let postgreSQLConfig = try PostgreSQLDatabaseConfig(env: Environment.self)
        let postgresql = PostgreSQLDatabase(config: postgreSQLConfig)

        /// Register the configured PostgreSQL database to the database config.
        var databases = DatabasesConfig()
        databases.enableLogging(on: .psql)
        databases.add(database: postgresql, as: .psql)
        services.register(databases)

        services.register(PostgreSQLDatabaseService.self)
    }
}

enum AppError: Error {
    case parameterMissing
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
