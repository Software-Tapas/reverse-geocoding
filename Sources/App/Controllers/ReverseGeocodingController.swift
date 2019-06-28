import Vapor

class ReverseGeocodingController: RouteCollection {
    func boot(router: Router) throws {
        router.get(Float.parameter, Float.parameter, use: reverseGeocoding)
        router.post(use: multiReverseGeocoding)
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

    private func generateResult(for places: [Place]) throws -> PlaceResponse {
        do {
            return try PlaceResponse.result(for: places, coordinate: Coordinate.zero)
        } catch {
            throw Abort(.notFound)
        }
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

    func multiReverseGeocoding(req: Request) throws -> Future<PlaceResponse> {
        let persistencyService = try req.make(DatabaseFetchable.self)
        return try req.content.decode(MultiCoordinateRequest.self)
            .flatMap { (content) -> Future<[Place]> in
                let coordinates = content.coordinates
                // Check the cache first
                return try persistencyService.fetchPlaces(forCoordinates: coordinates)
            }
            .map({ (places) in
                return try self.generateResult(for: places)
            })
    }
}

extension Place: Content { }

extension PlaceResponse: Content { }

extension Coordinate: Content { }

struct MultiCoordinateRequest: Content {
    let coordinates: [Coordinate]
}
