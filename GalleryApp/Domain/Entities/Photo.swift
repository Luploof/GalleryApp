import Foundation

struct Photo {
    let id: String
    let description: String?
    let urls: PhotoURLs
}

struct PhotoURLs: Codable {
    let thumb: URL
    let full: URL
}
