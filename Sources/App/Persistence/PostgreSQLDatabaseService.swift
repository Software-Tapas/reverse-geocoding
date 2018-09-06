import Vapor
import PostgreSQL

final class PostgreSQLDatabaseService: DatabaseFetchable {
    static func makeService(for worker: Container) throws -> PostgreSQLDatabaseService {
        return PostgreSQLDatabaseService(container: worker)
    }

    private var container: Container

    init(container: Container) {
        self.container = container
    }

    func fetchPlaces(forCoordinate coordinate: Coordinate) -> EventLoopFuture<[Place]> {
        return container.withPooledConnection(to: .psql, closure: { (conn: PostgreSQLDatabase.Connection) -> EventLoopFuture<[Place]> in
            let placesFuture = conn.raw("""
                SELECT name, "name:en" as name_en, "name:de" as name_de, admin_level, way_area from place_polygon
                WHERE ST_CONTAINS(way,  ST_Transform(ST_SetSRID(ST_Point(\(coordinate.longitude), \(coordinate.latitude)), 4326), 3857))
                ORDER BY admin_level DESC;
                """)
                .all(decoding: Place.self)
            return placesFuture
        })
    }
}
