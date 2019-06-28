import Vapor

protocol DatabaseFetchable: ServiceType {

    func fetchPlaces(forCoordinate coordinate: Coordinate) -> EventLoopFuture<[Place]>
    func fetchPlaces(forCoordinates coordinates: [Coordinate]) throws -> EventLoopFuture<[Place]>
}
