import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic health endpoint for docker
    router.get("health") { req in
        return HTTPResponseStatus(statusCode: 200)
    }
    let reverseGeocodingController = ReverseGeocodingController()
    try router.grouped("location").register(collection: reverseGeocodingController)
}
