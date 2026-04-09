import Foundation

protocol ToggleFavoriteUseCase {
    func execute(photo: Photo) -> Bool
}

class ToggleFavoriteUseCaseImpl: ToggleFavoriteUseCase {
    private let repository: FavoriteRepository
    
    init(repository: FavoriteRepository) {
        self.repository = repository
    }
    
    func execute(photo: Photo) -> Bool {
        if repository.isFavorite(photoId: photo.id) {
            repository.remove(photoId: photo.id)
            return false
        } else {
            repository.add(photo: photo)
            return true
        }
    }
}
