import Foundation

extension Notification.Name {
    static let favoriteChanged = Notification.Name("favoriteChanged")
}

@MainActor
class GalleryViewModel {
    private let fetchPhotosUseCase: FetchPhotosUseCase
    private let getFavoritesUseCase: GetFavoritesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    
    var photos: [Photo] = []
    var onStateChanged: (() -> Void)?
    var isLoading: Bool = false
    var error: NetworkError?
    
    private var currentPage: Int = 1
    private var canLoadMore: Bool = true
    private var isLoadingMore: Bool = false
    private var notificationObserver: NSObjectProtocol?
    
    init(fetchPhotosUseCase: FetchPhotosUseCase, getFavoritesUseCase: GetFavoritesUseCase, toggleFavoriteUseCase: ToggleFavoriteUseCase) {
        self.fetchPhotosUseCase = fetchPhotosUseCase
        self.getFavoritesUseCase = getFavoritesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        
        Task { await loadMorePhotos() }
        
        setupNotificationObserver()
    }
    
    private func setupNotificationObserver() {
        notificationObserver = NotificationCenter.default.addObserver(
            forName: .favoriteChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                guard let self = self,
                      let userInfo = notification.userInfo,
                      let photoId = userInfo["photoId"] as? String,
                      let isFavorite = userInfo["isFavorite"] as? Bool else { return }
                
                self.updateFavoriteStatus(photoId: photoId, isFavorite: isFavorite)
            }
        }
    }
    
    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func loadMorePhotos() async {
        guard !isLoadingMore && canLoadMore else { return }
        
        isLoadingMore = true
        if photos.isEmpty { isLoading = true }
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
                Photo(
                    id: photo.id,
                    title: photo.title,
                    description: photo.description,
                    urls: photo.urls,
                    isFavorite: favoriteSet.contains(photo.id)
                )
            }
            
            self.photos.append(contentsOf: processedPhotos)
            self.currentPage += 1
            self.canLoadMore = newPhotos.count == 30
            self.error = nil
            
        } catch let error as NetworkError {
            self.error = error
        } catch {
            self.error = .unknown(underlyingError: error)
        }
    }
    
    func updateFavoriteStatus(photoId: String, isFavorite: Bool) {
        guard let index = photos.firstIndex(where: { $0.id == photoId }) else { return }
        let old = photos[index]
        photos[index] = Photo(id: old.id, title: old.title, description: old.description, urls: old.urls, isFavorite: isFavorite)
        onStateChanged?()
    }
    
    func toggleFavorite(photo: Photo) {
        let newStatus = toggleFavoriteUseCase.execute(photo: photo)
        updateFavoriteStatus(photoId: photo.id, isFavorite: newStatus)
        NotificationCenter.default.post(name: .favoriteChanged, object: nil, userInfo: ["photoId": photo.id, "isFavorite": newStatus])
    }
}
