import Vapor

/// Register your application's routes here.
func routes(_ app: Application) throws {
    // Basic health endpoint for docker
    app.get("health") { _ in
        return HTTPStatus.ok
    }
    
    // Register the main controller
    try app.grouped("location")
        .register(collection: ReverseGeocodingController())
}
