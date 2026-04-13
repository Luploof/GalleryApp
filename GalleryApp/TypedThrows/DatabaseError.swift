import Foundation

enum DatabaseError: Error {
    case saveFailed(underlyingError: Error)
    case deleteFailed(underlyingError: Error)
    case fetchFailed(underlyingError: Error)
    case invalidEntity
    case alreadyExists
    case notFound
    
    var localizedDescription: String {
        switch self {
        case .saveFailed:
            return "Failed to save to favorites"
        case .deleteFailed:
            return "Failed to remove from favorites"
        case .fetchFailed:
            return "Failed to load favorites from database"
        case .invalidEntity:
            return "Database entity is corrupted"
        case .alreadyExists:
            return "Photo already in favorites"
        case .notFound:
            return "Photo not found in favorites"
        }
    }
}
