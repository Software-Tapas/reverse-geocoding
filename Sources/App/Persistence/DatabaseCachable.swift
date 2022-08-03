import Vapor

protocol DatabaseCachable {
    func fetchPlaces(forCoordinate coordinate: Coordinate) async throws -> PlaceResponse?

    func store(response: PlaceResponse, for coordinate: Coordinate) async throws
}
