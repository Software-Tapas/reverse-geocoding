struct PlaceTuple {
    let primaryPlace: Place
    let secondaryPlace: Place

    func name(forLanguage language: Language) -> String {
        return [
            primaryPlace.nameOrNil(forLanguage: language),
            secondaryPlace.nameOrNil(forLanguage: language)
        ]
        .compactMap({ $0 })
        .joined(separator: ", ")
    }
}
