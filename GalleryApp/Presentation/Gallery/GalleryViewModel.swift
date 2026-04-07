import Foundation

extension Notification.Name {
    static let favoriteChanged = Notification.Name("favoriteChanged")
}

class GalleryViewModel {
    private let fetchPhotosUseCase: FetchPhotosUseCase
    private let getFavoritesUseCase: GetFavoritesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    var photos: [Photo] = []
    var onStateChanged: (() -> Void)?
    var isLoading: Bool = false
    var errorMessage: String? = nil
    private var currentPage: Int = 1
    private var canLoadMore: Bool = true
    private var isLoadingMore: Bool = false
    private var notificationObserver: NSObjectProtocol?
    
    
    init(fetchPhotosUseCase: FetchPhotosUseCase, getFavoritesUseCase: GetFavoritesUseCase, toggleFavoriteUseCase: ToggleFavoriteUseCase) {
        self.fetchPhotosUseCase = fetchPhotosUseCase
        self.getFavoritesUseCase = getFavoritesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        Task { await loadMorePhotos() }
        
        notificationObserver = NotificationCenter.default.addObserver(
            forName: .favoriteChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo,
                  let photoId = userInfo["photoId"] as? String,
                  let isFavorite = userInfo["isFavorite"] as? Bool else { return }
            self.updateFavoriteStatus(photoId: photoId, isFavorite: isFavorite)
        }
    }
    
    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func loadMorePhotos() async {
        if isLoadingMore || !canLoadMore {
            return
        }
        isLoadingMore = true
        isLoading = true
        onStateChanged?()
        defer {
            isLoadingMore = false
            isLoading = false
            onStateChanged?()
        }
        
        do {
            let newPhotos = try await fetchPhotosUseCase.execute(page: currentPage, perPage: 30)
            let favoriteIds = getFavoritesUseCase.execute()
            
            let favoriteSet = Set(favoriteIds)
            let processedPhotos = newPhotos.map { photo in
                return Photo(
                    id: photo.id,
                    title: photo.title,
                    description: photo.description,
                    urls: photo.urls,
                    isFavorite: favoriteSet.contains(photo.id)
                )
            }
            
            photos.append(contentsOf: processedPhotos)
            
            currentPage += 1
            
            if newPhotos.count < 30 {
                canLoadMore = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateFavoriteStatus(photoId: String, isFavorite: Bool) {
        photos = photos.map { photo in
            guard photo.id == photoId else { return photo }
            return Photo(
                id: photo.id,
                title: photo.title,
                description: photo.description,
                urls: photo.urls,
                isFavorite: isFavorite
            )
        }
        onStateChanged?()
    }
    
    func toggleFavorite(photoId: String) {
        let newStatus =  toggleFavoriteUseCase.execute(photoId: photoId)
        updateFavoriteStatus(photoId: photoId, isFavorite: newStatus)
        NotificationCenter.default.post(name: .favoriteChanged, object: nil, userInfo: ["photoId": photoId, "isFavorite": newStatus])
    }
}

