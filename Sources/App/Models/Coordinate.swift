struct Coordinate: Codable {
    let longitude: Float
    let latitude: Float
}

extension Coordinate {
    static var zero: Coordinate {
        return Coordinate(longitude: 0, latitude: 0)
    }
}

extension Coordinate: Equatable { }
extension Coordinate: Hashable { }
