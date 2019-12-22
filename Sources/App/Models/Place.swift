import Foundation

struct Place: Codable {
    let name: String?
    let name_de: String?
    let name_en: String?
    var adminLevel: Int {
        guard let admin_level = admin_level else { return 0 }
        return admin_level
    }
    private let admin_level: Int?
    let way_area: Double?

    func name(forLanguage language: Language) -> String? {
        switch language {
        case .en:
            return name_en ?? name ?? name_de
        case .de:
            return name_de ?? name_en ?? name
        }
    }

    func nameOrNil(forLanguage language: Language) -> String? {
        return name(forLanguage: language)
    }

    init(name: String?, name_de: String?, name_en: String?, admin_level: Int?, way_area: Double?) {
        self.name = name
        self.name_de = name_de
        self.name_en = name_en
        self.admin_level = admin_level
        self.way_area = way_area
    }
}

extension Place: Equatable {
    public static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.name == rhs.name && lhs.name_de == rhs.name_de && lhs.name_en == rhs.name_en
    }
}

extension Place {

    /// Checks if the place is relevant as a secondary place for the parameter place
    ///
    /// - Parameter primaryPlace: Primary place
    /// - Returns: Result if self is relevant
    /// - Throws: PlaceResponseError.emptyName if the name of primary place is nil
    func isPlaceRelevant(for primaryPlace: Place) throws -> Bool {
        guard let placeName = primaryPlace.name else {
            throw PlaceResponseError.emptyName
        }
        return self != primaryPlace &&
            self.name?.contains(placeName) == false &&
            placeName.contains(self.name ?? String()) == false &&
            adminLevel != 5
    }
}
