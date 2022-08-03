import Vapor
import SQLKit

final class PostgreSQLDatabaseService: DatabaseFetchable {
    private var db: SQLDatabase

    init(db: SQLDatabase) {
        self.db = db
    }
    
    func fetchPlaces(forCoordinate coordinate: Coordinate) async throws -> [Place] {
        try await db.raw("""
            SELECT name, "name:en" as name_en, "name:de" as name_de, admin_level, way_area from place_polygon
            WHERE ST_CONTAINS(way,  ST_Transform(ST_SetSRID(ST_Point(\(bind: coordinate.longitude), \(bind: coordinate.latitude)), 4326), 3857))
            ORDER BY admin_level DESC;
            """)
        .all(decoding: Place.self)
    }
    
    func fetchPlaces(forCoordinates coordinates: [Coordinate]) async throws -> [Place] {
        guard coordinates.count > 0 else { throw Error.noCoordinatesSupplied }
        // Build a dynamic where clause that is then past into the actual query later
        let conditions = coordinates.map { (coordinate) in
            return "ST_CONTAINS(way,  ST_Transform(ST_SetSRID(ST_Point(\(coordinate.longitude), \(coordinate.latitude)), 4326), 3857))"
        }
        let whereClause = conditions.joined(separator: " AND ")
        
        return try await db.raw("""
            SELECT name, "name:en" as name_en, "name:de" as name_de, admin_level, way_area from place_polygon
            WHERE \(raw: whereClause)
            ORDER BY admin_level DESC;
            """)
        .all(decoding: Place.self)
    }

    enum Error: Swift.Error {
        case noCoordinatesSupplied
    }
}
