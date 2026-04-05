import Foundation

protocol ToggleFavoriteUseCase {
    func execute(photoId: String) -> Bool
}

class ToggleFavoriteUseCaseImpl: ToggleFavoriteUseCase {
    private let repository: FavoriteRepository
    
    init(repository: FavoriteRepository) {
        self.repository = repository
    }
    
    func execute(photoId: String) -> Bool {
        if repository.isFavorite(photoId: photoId) {
            repository.remove(photoId: photoId)
            return false
        } else {
            repository.add(photoId: photoId)
            return true
        }
    }
}
