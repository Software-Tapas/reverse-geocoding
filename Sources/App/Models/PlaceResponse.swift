import Foundation

enum PlaceResponseError: Error {
    case emptyPlaceList
    case emptyName
}

struct PlaceResponse: Codable {
    let de: String?
    let en: String?
    let coordinate: Coordinate
}

extension PlaceResponse {

    static func result(for places: [Place], coordinate: Coordinate) throws -> PlaceResponse {
        // Check if the place list contains any places otherwise return nil
        guard let firstPlace = places.first, places.count > 0 else {
            throw PlaceResponseError.emptyPlaceList
        }
        // Check if firstplace admin level is biger than 6 else return the first place with the coutry as result
        guard let secondaryPlace = try secondRelevantPlace(for: firstPlace, in: places), firstPlace.adminLevel >= 6 else {
            if let countryPlace = places.last, countryPlace != firstPlace {
                let placeTuple = PlaceTuple(primaryPlace: firstPlace, secondaryPlace: places.last!)
                return PlaceResponse(places: placeTuple, coordinate: coordinate)
            } else {
                return result(forPrimaryPlace: firstPlace, coordinate: coordinate)
            }
        }
        let placeTuple = PlaceTuple(primaryPlace: firstPlace, secondaryPlace: secondaryPlace)
        return PlaceResponse(places: placeTuple, coordinate: coordinate)
    }

    private static func secondRelevantPlace(for firstPlace: Place, in places: [Place]) throws -> Place? {
        let nextRelevantPlace = try places.first(where: { try $0.isPlaceRelevant(for: firstPlace) })
        return nextRelevantPlace
    }

    private static func result(forPrimaryPlace primaryPlace: Place, coordinate: Coordinate) -> PlaceResponse {
        return PlaceResponse(de: primaryPlace.name(forLanguage: .de), en: primaryPlace.name(forLanguage: .en), coordinate: coordinate)
    }

    init(places: PlaceTuple, coordinate: Coordinate) {
        self.de = places.name(forLanguage: .de)
        self.en = places.name(forLanguage: .en)
        self.coordinate = coordinate
    }
}
