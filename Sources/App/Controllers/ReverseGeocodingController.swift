import Vapor

class ReverseGeocodingController: RouteCollection {
    func boot(router: Router) throws {
        router.get(Float.parameter, Float.parameter, use: reverseGeocoding)
    }

    fileprivate func fetchFromPersistance(_ req: Request, _ coordinate: Coordinate) throws -> EventLoopFuture<PlaceResponse> {
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

    func reverseGeocoding(req: Request) throws -> Future<PlaceResponse> {
        let lat = try req.parameters.next(Float.self)
        let lon = try req.parameters.next(Float.self)
        let coordinate = Coordinate(longitude: lon, latitude: lat)
        let cacheService = try req.make(DatabaseCachable.self)
        let cacheResponse = cacheService.fetchPlaces(forCoordinate: coordinate)
        return cacheResponse.flatMap { (response) -> (Future<PlaceResponse>) in
            if let response = response {
                return req.future(response)
            }
            let persistanceResult = try self.fetchFromPersistance(req, coordinate)
            persistanceResult.map({ (result) in
                try cacheService.store(response: result, for: coordinate)
            })
            return persistanceResult
        }
    }
}

extension Place: Content { }

extension PlaceResponse: Content { }

extension Coordinate: Content { }
