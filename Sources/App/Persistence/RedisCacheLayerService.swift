import Vapor
import Redis

final class RedisCacheLayerService: DatabaseCachable {
    static func makeService(for worker: Container) throws -> RedisCacheLayerService {
        return RedisCacheLayerService(container: worker)
    }

    private var container: Container

    init(container: Container) {
        self.container = container
    }

    func fetchPlaces(forCoordinate coordinate: Coordinate) -> EventLoopFuture<PlaceResponse?> {
        return container.withNewConnection(to: .redis, closure: { (conn: RedisDatabase.Connection) -> EventLoopFuture<PlaceResponse?> in
            return conn.get(coordinate.key, as: PlaceResponse.self)
        })
    }

    func store(response: PlaceResponse, for coordinate: Coordinate) throws -> EventLoopFuture<Void> {
        return container.withNewConnection(to: .redis, closure: { (conn: RedisDatabase.Connection) -> EventLoopFuture<Void> in
            return conn.set(coordinate.key, to: response)
        })
    }

    func purgeAllData() throws -> EventLoopFuture<Void> {
        return container.withNewConnection(to: .redis, closure: { (database) -> EventLoopFuture<Void> in
            return database.command("FLUSHDB")
                .transform(to: Void())
        })
    }
}

enum ConvertError: Error {
    case noData
}

extension PlaceResponse: RedisDataConvertible {
    static func convertFromRedisData(_ data: RedisData) throws -> PlaceResponse {
        let decoder = JSONDecoder()
        guard let jsonData = data.data else {
            throw ConvertError.noData
        }
        return try decoder.decode(PlaceResponse.self, from: jsonData)
    }

    func convertToRedisData() throws -> RedisData {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        let json = String(data: data, encoding: .utf8)
        return RedisData(stringLiteral: json!)
    }
}

extension Coordinate {
    var key: String {
        return "\(self.latitude);\(self.latitude)"
    }
}

struct PurgeRedisCache: Command {
    var arguments: [CommandArgument] {
        return []
    }

    var options: [CommandOption] {
        return []
    }

    var help: [String] {
        return ["Purges all cached data in Redis"]
    }

    func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        let logger = try context.container.make(Logger.self)
        guard let redisService = try? context.container.make(RedisCacheLayerService.self) else {
            logger.error("No Redis caching layer is registered")
            return context.container.future()
        }
        logger.warning("Start purging all Redis cached data")

        return try redisService.purgeAllData().do({ () in
            logger.info("Purging Succeeded")
        })
    }
}
