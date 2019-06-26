struct Coordinate: Codable {
    let longitude: Float
    let latitude: Float
}

extension Coordinate: Equatable { }
extension Coordinate: Hashable { }
