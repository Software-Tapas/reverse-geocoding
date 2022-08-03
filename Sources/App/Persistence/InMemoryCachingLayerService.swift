import Vapor

final class InMemoryCachingLayerService: DatabaseCachable {
    private var data: [Coordinate: PlaceResponse] = [:]

    func fetchPlaces(forCoordinate coordinate: Coordinate) async throws -> PlaceResponse? {
        self.data[coordinate]
    }
    
    func store(response: PlaceResponse, for coordinate: Coordinate) async throws {
        self.data[coordinate] = response
    }
}
