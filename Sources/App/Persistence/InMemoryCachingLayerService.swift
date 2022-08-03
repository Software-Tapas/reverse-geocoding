import Vapor

/// In-memory caching layer, that can be used for example for testing purposes.
final class InMemoryCachingLayerService: DatabaseCachable {
    private var data: [Coordinate: PlaceResponse] = [:]

    func fetchPlaces(forCoordinate coordinate: Coordinate) async throws -> PlaceResponse? {
        self.data[coordinate]
    }
    
    func store(response: PlaceResponse, for coordinate: Coordinate) async throws {
        self.data[coordinate] = response
    }
}
