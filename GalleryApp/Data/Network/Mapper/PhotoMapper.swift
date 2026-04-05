import Foundation

struct PhotoMapper {
    static func toDomain(from response: PhotoResponse, isFavorite: Bool) -> Photo? {
        guard let thumbURL = URL(string: response.urls.thumb),
              let fullURL = URL(string: response.urls.full) else {
            return nil
        }
        let urls = PhotoURLs(thumb: thumbURL, full: fullURL)
        let photo = Photo(
            id: response.id,
            description: response.description,
            urls: urls,
            isFavorite: isFavorite
        )
        return photo
    }
}
