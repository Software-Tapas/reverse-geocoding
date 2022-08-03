import Vapor
import Redis
import RediStack

final class RedisCacheLayerService: DatabaseCachable {
    private var redis: Application.Redis
    
    init(redis: Application.Redis) {
        self.redis = redis
    }
    
    func fetchPlaces(forCoordinate coordinate: Coordinate) async throws -> PlaceResponse? {
        try await redis.get(coordinate.key, asJSON: PlaceResponse.self).get()
    }
    
    func store(response: PlaceResponse, for coordinate: Coordinate) async throws {
        try await redis.set(coordinate.key, toJSON: response)
    }
    
    func purgeAllData() async throws {
        _ = try await redis.send(command: "FLUSHDB").get()
    }
}

extension Coordinate {
    var key: RedisKey {
        .init("\(self.latitude);\(self.latitude)")
    }
}
