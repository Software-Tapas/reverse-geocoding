import Vapor
import XCTest
@testable import App

class ReverseGeocodingTests: XCTestCase {
    var app: Application!

    override func setUp() {
        super.setUp()

        app = try! Application.testable()
    }

    func testEmptyResult() throws {
        let places = [Place]()
        let coordinate = Coordinate(longitude: 0, latitude: 0)
        XCTAssertThrowsError(try PlaceResponse.result(for: places, coordinate: coordinate), "Result is not empty") { (error) in
            XCTAssertEqual(error as? PlaceResponseError, .emptyPlaceList)
        }
    }

    func testResultWithEmptyNames() throws {
        let places = [Place(name: nil, name_de: nil, name_en: nil, admin_level: nil, way_area: nil)]
        let coordinate = Coordinate(longitude: 0, latitude: 0)
        XCTAssertThrowsError(try PlaceResponse.result(for: places, coordinate: coordinate), "Result is not not an empty name") { (error) in
            XCTAssertEqual(error as? PlaceResponseError, .emptyName)
        }
    }

    func testResultWithOnePlace() throws {
        let places = [Place(name: "name", name_de: "name_de", name_en: "name_en", admin_level: 6, way_area: nil)]
        let coordinate = Coordinate(longitude: 0, latitude: 0)
        let result = try PlaceResponse.result(for: places, coordinate: coordinate)
        XCTAssertEqual(result.de, "name_de")
        XCTAssertEqual(result.en, "name_en")
        XCTAssertEqual(result.coordinate, coordinate)
    }

    func testResultWithTwoLowPlaces() throws {
        let places = [Place(name: "1.", name_de: "Erster", name_en: "first", admin_level: 18, way_area: nil),
                      Place(name: "2.", name_de: "Zweiter", name_en: "second", admin_level: 10, way_area: nil)]
        let coordinate = Coordinate(longitude: 0, latitude: 0)
        let result = try PlaceResponse.result(for: places, coordinate: coordinate)
        XCTAssertEqual(result.de, "Erster, Zweiter")
        XCTAssertEqual(result.en, "first, second")
        XCTAssertEqual(result.coordinate, coordinate)
    }

    func testResultWithThreePlaces() throws {
        let places = [Place(name: "1.", name_de: "Erster", name_en: "first", admin_level: 18, way_area: nil),
                      Place(name: "2.", name_de: "Zweiter", name_en: "second", admin_level: 10, way_area: nil),
                      Place(name: "3.", name_de: "Dritter", name_en: "thried", admin_level: 10, way_area: nil)]
        let coordinate = Coordinate(longitude: 0, latitude: 0)
        let result = try PlaceResponse.result(for: places, coordinate: coordinate)
        XCTAssertEqual(result.de, "Erster, Zweiter")
        XCTAssertEqual(result.en, "first, second")
        XCTAssertEqual(result.coordinate, coordinate)
    }

    func testResultWithTwoHighPlaces() throws {
        let places = [Place(name: "1.", name_de: "Erster", name_en: "first", admin_level: 5, way_area: nil),
                      Place(name: "2.", name_de: "Zweiter", name_en: "second", admin_level: 4, way_area: nil)]
        let coordinate = Coordinate(longitude: 0, latitude: 0)
        let result = try PlaceResponse.result(for: places, coordinate: coordinate)
        XCTAssertEqual(result.de, "Erster")
        XCTAssertEqual(result.en, "first")
        XCTAssertEqual(result.coordinate, coordinate)
    }

    func testResultWithTwoEqualNames() throws {
        let places = [Place(name: "name", name_de: "name_de", name_en: "name_en", admin_level: 18, way_area: nil),
                      Place(name: "name", name_de: "name_de", name_en: "name_en", admin_level: 10, way_area: nil)]
        let coordinate = Coordinate(longitude: 0, latitude: 0)
        let result = try PlaceResponse.result(for: places, coordinate: coordinate)
        XCTAssertEqual(result.de, "name_de")
        XCTAssertEqual(result.en, "name_en")
        XCTAssertEqual(result.coordinate, coordinate)
    }

    func testResultWithTwoEqualNamesAndAnother() throws {
        let places = [Place(name: "name", name_de: "name_de", name_en: "name_en", admin_level: 18, way_area: nil),
                      Place(name: "name", name_de: "name_de", name_en: "name_en", admin_level: 10, way_area: nil),
                      Place(name: "Berlin", name_de: "Berlin", name_en: "Berlin", admin_level: 4, way_area: nil)]
        let coordinate = Coordinate(longitude: 0, latitude: 0)
        let result = try PlaceResponse.result(for: places, coordinate: coordinate)
        XCTAssertEqual(result.de, "name_de, Berlin")
        XCTAssertEqual(result.en, "name_en, Berlin")
        XCTAssertEqual(result.coordinate, coordinate)
    }
}

extension ReverseGeocodingTests {
    static let allTests = [
        ("testEmptyResult", testEmptyResult),
        ("testResultWithEmptyNames", testResultWithEmptyNames),
        ("testResultWithOnePlace", testResultWithOnePlace),
        ("testResultWithTwoLowPlaces", testResultWithTwoLowPlaces),
        ("testResultWithThreePlaces", testResultWithThreePlaces),
        ("testResultWithTwoHighPlaces", testResultWithTwoHighPlaces),
        ("testResultWithTwoEqualNames", testResultWithTwoEqualNames),
        ("testResultWithTwoEqualNamesAndAnother", testResultWithTwoEqualNamesAndAnother),
    ]
}
