import Foundation

class FavoritesViewModel {
    private let favoriteRepository: FavoriteRepository
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private var notificationObserver: NSObjectProtocol?
    var onStateChanged: (() -> Void)?
    var favoritePhotos: [Photo] = []
    
    init(favoriteRepository: FavoriteRepository, toggleFavoriteUseCase: ToggleFavoriteUseCase) {
        self.favoriteRepository = favoriteRepository
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        notificationObserver = NotificationCenter.default.addObserver(
            forName: .favoriteChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadFavorites()
        }
        loadFavorites()
    }
    
    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func loadFavorites() {
        favoritePhotos = favoriteRepository.getAllFavoritePhotos()
        onStateChanged?()
    }
    
    func removeFromFavorites(photoId: String) {
        if let foundPhoto = favoritePhotos.first(where: { $0.id == photoId }) {
            toggleFavoriteUseCase.execute(photo: foundPhoto)
            loadFavorites()
        }
    }
    
}
