import Vapor

protocol DatabaseFetchable: ServiceType {

    func fetchPlaces(forCoordinate coordinate: Coordinate) -> EventLoopFuture<[Place]>
}
