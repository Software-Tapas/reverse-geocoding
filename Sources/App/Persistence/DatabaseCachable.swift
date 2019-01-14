import Vapor

protocol DatabaseCachable: ServiceType {

    func fetchPlaces(forCoordinate coordinate: Coordinate) -> EventLoopFuture<PlaceResponse?>
    func store(response: PlaceResponse, for coordinate: Coordinate) throws -> EventLoopFuture<Void>
}
