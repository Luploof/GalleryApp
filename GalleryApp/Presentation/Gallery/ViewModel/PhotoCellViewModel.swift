import UIKit

@MainActor
class PhotoCellViewModel {
    private let imageLoader: ImageLoaderProtocol
    private let photo: Photo
    
    private(set) var image: UIImage?
    private(set) var isLoading = false
    private(set) var error: ImageLoadingError?
    
    var onStateChanged: (() -> Void)?
    
    init(photo: Photo, imageLoader: ImageLoaderProtocol = ImageLoader()) {
        self.photo = photo
        self.imageLoader = imageLoader
    }
    
    var isFavorite: Bool {
        return photo.isFavorite
    }
    
    var photoId: String {
        return photo.id
    }
    
    var thumbURL: URL {
        return photo.urls.thumb
    }
    
    func loadImage() {
        guard !isLoading else { return }
        
        isLoading = true
        onStateChanged?()
        
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let image = try await self.imageLoader.loadImage(from: self.thumbURL)
                self.image = image
                self.isLoading = false
                self.onStateChanged?()
            } catch let error as ImageLoadingError {
                self.error = error
                self.isLoading = false
                self.onStateChanged?()
            } catch {
                self.error = .downloadFailed(url: self.thumbURL, underlyingError: error)
                self.isLoading = false
                self.onStateChanged?()
            }
        }
    }
}
