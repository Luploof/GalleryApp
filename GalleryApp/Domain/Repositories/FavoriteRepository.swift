import Foundation

protocol FavoriteRepository: AnyObject {
    func add(photoId: String)
    func remove(photoId: String)
    func isFavorite(photoId: String) -> Bool
    func getAllFavorites() -> [String]
}

