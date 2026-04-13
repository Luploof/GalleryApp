import Foundation
import UIKit

@MainActor
class DetailViewModel {
    private var allPhotos: [Photo]
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let imageLoader: ImageLoaderProtocol
    
    private var currentIndex: Int
    private var currentPhoto: Photo
    var photo: Photo { currentPhoto }
    private(set) var currentImage: UIImage?
    
    var onPhotoChanged: ((Photo) -> Void)?
    var onImageLoaded: ((UIImage) -> Void)?
    
    init(photo: Photo,
         allPhotos: [Photo],
         toggleFavoriteUseCase: ToggleFavoriteUseCase,
         imageLoader: ImageLoaderProtocol = ImageLoader()) {
        self.allPhotos = allPhotos
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.imageLoader = imageLoader
        self.currentIndex = allPhotos.firstIndex(where: { $0.id == photo.id }) ?? 0
        self.currentPhoto = allPhotos[currentIndex]
    }
    
    func loadImageForCurrentPhoto() async {
        let url = currentPhoto.urls.full
        do {
            let image = try await imageLoader.loadImage(from: url)
            self.currentImage = image
            self.onImageLoaded?(image)
        } catch {
            print("Failed to load image: \(error)")
        }
    }
    
    func next() {
        guard currentIndex + 1 < allPhotos.count else { return }
        currentIndex += 1
        currentPhoto = allPhotos[currentIndex]
        onPhotoChanged?(currentPhoto)
        Task { await loadImageForCurrentPhoto() }
    }
    
    func previous() {
        guard currentIndex - 1 >= 0 else { return }
        currentIndex -= 1
        currentPhoto = allPhotos[currentIndex]
        onPhotoChanged?(currentPhoto)
        Task { await loadImageForCurrentPhoto() }
    }
    
    func toggleFavorite() {
        let newStatus = toggleFavoriteUseCase.execute(photo: currentPhoto)
        let updatedPhoto = Photo(
            id: currentPhoto.id,
            title: currentPhoto.title,
            description: currentPhoto.description,
            urls: currentPhoto.urls,
            isFavorite: newStatus
        )
        currentPhoto = updatedPhoto
        
        if let index = allPhotos.firstIndex(where: { $0.id == currentPhoto.id }) {
            allPhotos[index] = updatedPhoto
        }
        
        onPhotoChanged?(currentPhoto)
        NotificationCenter.default.post(
            name: .favoriteChanged,
            object: nil,
            userInfo: ["photoId": currentPhoto.id, "isFavorite": newStatus]
        )
    }
}
