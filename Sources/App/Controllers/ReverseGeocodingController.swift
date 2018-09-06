import Vapor

class ReverseGeocodingController: RouteCollection {
    func boot(router: Router) throws {
        router.get(Float.parameter, Float.parameter, use: reverseGeocoding)
    }

    func reverseGeocoding(req: Request) throws -> EventLoopFuture<PlaceResponse> {
        let lat = try req.parameters.next(Float.self)
        let lon = try req.parameters.next(Float.self)
        let coordinate = Coordinate(longitude: lon, latitude: lat)
        let persistencyService = try req.make(DatabaseFetchable.self)
        let places = persistencyService.fetchPlaces(forCoordinate: coordinate)
        return places.map({ (places) -> (PlaceResponse) in
            do {
                return try PlaceResponse.result(for: places, coordinate: coordinate)
            } catch {
                throw Abort(.notFound)
            }
        })
    }
}

extension Place: Content { }

extension PlaceResponse: Content { }

extension Coordinate: Content { }
