import Foundation

protocol GetFavoritesUseCase {
    func execute() -> [String]
}

class GetFavoritesUseCaseImpl: GetFavoritesUseCase {
    private let repository: FavoriteRepository
    
    init(repository: FavoriteRepository) {
        self.repository = repository
    }
    
    func execute() -> [String] {
        return repository.getAllFavorites()
    }
}
