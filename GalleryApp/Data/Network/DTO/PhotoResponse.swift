import Foundation

struct PhotoResponse: Decodable {
    let id: String
    let title: String?
    let description: String?
    let urls: Urls
}

struct Urls: Decodable {
    let thumb: String
    let full: String
}
