import Vapor
import SQLKit

class ReverseGeocodingController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.get(":lat", ":long",  use: reverseGeocoding)
        routes.post(use: multiReverseGeocoding)
    }
    
    private func fetchFromPersistance(_ fetch: DatabaseFetchable, _ coordinate: Coordinate) async throws -> PlaceResponse {
        let places = try await fetch.fetchPlaces(forCoordinate: coordinate)
        do {
            return try PlaceResponse.result(for: places, coordinate: coordinate)
        } catch {
            throw Abort(.notFound)
        }
    }
    
    private func reverseGeocoding(req: Request) async throws -> PlaceResponse {
        guard let lat = req.parameters.get("lat", as: Float.self) else { throw Abort(.badRequest) }
        guard let long = req.parameters.get("long", as: Float.self) else { throw Abort(.badRequest) }
        
        let coordinate = Coordinate(longitude: long, latitude: lat)
        if let cacheResponse = try await req.cacheService.fetchPlaces(forCoordinate: coordinate) {
            return cacheResponse
        } else {
            let result = try await fetchFromPersistance(req.fetchService, coordinate)
            try await req.cacheService.store(response: result, for: coordinate)
            return result
        }
        
    }
    
    private func generateResult(for places: [Place]) throws -> PlaceResponse {
        do {
            return try PlaceResponse.result(for: places, coordinate: Coordinate.zero)
        } catch {
            throw Abort(.notFound)
        }
    }
    
    private func multiReverseGeocoding(req: Request) async throws -> PlaceResponse {
        let body = try req.content.decode(MultiCoordinateRequest.self)
        let places = try await req.fetchService.fetchPlaces(forCoordinates: body.coordinates)
        return try self.generateResult(for: places)
    }
}

extension Place: Content { }

extension PlaceResponse: Content { }

extension Coordinate: Content { }

struct MultiCoordinateRequest: Content {
    let coordinates: [Coordinate]
}

extension Request {
    var cacheService: DatabaseCachable {
        if self.application.environment == .testing {
            return InMemoryCachingLayerService()
        } else {
            return RedisCacheLayerService(redis: self.application.redis)
        }
    }
    
    var fetchService: DatabaseFetchable {
        guard let sqlDB = self.db as? SQLDatabase else { fatalError("Non-SQL databases are not supported") }
        return PostgreSQLDatabaseService(db: sqlDB)
    }
}
