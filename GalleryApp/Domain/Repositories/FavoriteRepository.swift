import Foundation

protocol FavoriteRepository: AnyObject {
    func add(photo: Photo)
    func remove(photoId: String)
    func isFavorite(photoId: String) -> Bool
    func getAllFavorites() -> [String]
    func getAllFavoritePhotos() -> [Photo]
}

