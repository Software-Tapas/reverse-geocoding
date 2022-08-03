import Vapor

protocol DatabaseFetchable {
    func fetchPlaces(forCoordinate coordinate: Coordinate) async throws -> [Place]
    
    func fetchPlaces(forCoordinates coordinates: [Coordinate]) async throws -> [Place]
}
