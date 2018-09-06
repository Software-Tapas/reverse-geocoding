struct PlaceTuple {
    let primaryPlace: Place
    let secondaryPlace: Place

    func name(forLanguage language: Language) -> String {
        return "\(primaryPlace.nameOrEmptyString(forLanguage: language)), \(secondaryPlace.nameOrEmptyString(forLanguage: language))"
    }
}
