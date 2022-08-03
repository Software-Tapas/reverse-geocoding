import Vapor

/// Vapor command struct to purge all content that exist in Redis cache
struct PurgeRedisCacheCommand: AnyCommand {
    var help: String {
        "Purges all cached data in Redis"
    }
    
    func run(using context: inout CommandContext) throws {
        let redisService = RedisCacheLayerService(redis: context.application.redis)
        context.application.logger.warning("Start purging all Redis cached data")
        
        let promise = context.application.eventLoopGroup.next().makePromise(of: Void.self)
        promise.completeWithTask {
            try await redisService.purgeAllData()
        }
        try promise.futureResult.wait()
        context.application.logger.info("Purging Succeeded")
    }
}
