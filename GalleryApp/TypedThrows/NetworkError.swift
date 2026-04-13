import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingFailed(underlyingError: Error)
    case noInternetConnection
    case rateLimitExceeded(retryAfter: Int)
    case missingAPIKey
    case unauthorized
    case unknown(underlyingError: Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid server address"
        case .invalidResponse(let statusCode):
            return "Server error: \(statusCode)"
        case .decodingFailed:
            return "Failed to parse server response"
        case .noInternetConnection:
            return "No internet connection"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later"
        case .missingAPIKey:
            return "API key missing. Check Config.plist"
        case .unauthorized:
            return "Authorization failed. Check your API key"
        case .unknown(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
