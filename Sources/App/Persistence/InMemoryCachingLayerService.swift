import Vapor

final class InMemoryCachingLayerService: DatabaseCachable {
    private var data: [Coordinate: PlaceResponse] = [:]
    private var container: Container
    init(container: Container) {
        self.container = container
    }

    func fetchPlaces(forCoordinate coordinate: Coordinate) -> EventLoopFuture<PlaceResponse?> {
        let data = self.data[coordinate]
        if data != nil {
            return container.future(data)
        } else {
            return container.future(nil)
        }
    }

    func store(response: PlaceResponse, for coordinate: Coordinate) throws -> EventLoopFuture<Void> {
        self.data[coordinate] = response
        return container.future()
    }

    static func makeService(for container: Container) throws -> InMemoryCachingLayerService {
        return InMemoryCachingLayerService(container: container)
    }
}
