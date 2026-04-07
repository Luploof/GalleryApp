import Foundation

struct Photo {
    let id: String
    let title: String?
    let description: String?
    let urls: PhotoURLs
    let isFavorite: Bool
}

struct PhotoURLs: Codable {
    let thumb: URL
    let full: URL
}
