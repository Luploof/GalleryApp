import Foundation

enum ImageLoadingError: Error {
    case invalidImageData
    case downloadFailed(url: URL, underlyingError: Error)
    case cancelled
    
    var localizedDescription: String {
        switch self {
        case .invalidImageData:
            return "Image data is corrupted"
        case .downloadFailed(let url, _):
            return "Failed to download image from \(url.lastPathComponent)"
        case .cancelled:
            return "Image loading was cancelled"
        }
    }
}
