import Foundation

protocol FavoriteRepository {
    func add(photo: Photo) throws
    func remove(photoId: String) throws
    func isFavorite(photoId: String) -> Bool
    func getAllFavorites() -> [String]
    func getAllFavoritePhotos() -> [Photo]
}
