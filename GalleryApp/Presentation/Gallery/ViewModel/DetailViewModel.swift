import Foundation

class DetailViewModel {
    private let allPhotos: [Photo]
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private var currentIndex: Int
    private var currentPhoto: Photo
    var photo: Photo { currentPhoto }
    
    var onPhotoChanged: ((Photo) -> Void)?
    
    init(photo: Photo, allPhotos: [Photo], toggleFavoriteUseCase: ToggleFavoriteUseCase) {
        self.allPhotos = allPhotos
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.currentIndex = allPhotos.firstIndex(where: { $0.id == photo.id }) ?? 0
        self.currentPhoto = allPhotos[currentIndex]
    }
    
    func next() {
        if currentIndex + 1 < allPhotos.count {
            currentIndex += 1
            currentPhoto = allPhotos[currentIndex]
            onPhotoChanged?(currentPhoto)
        }
        
    }
    
    func previous() {
        if currentIndex - 1 > 0 {
            currentIndex -= 1
            currentPhoto = allPhotos[currentIndex]
            onPhotoChanged?(currentPhoto)
        }
    }
    
    func toggleFavorite() {
        let newStatus  = toggleFavoriteUseCase.execute(photoId: currentPhoto.id)
        let updatedPhoto = Photo(id: currentPhoto.id,
                                 title: currentPhoto.title,
                                 description: currentPhoto.description,
                                 urls: currentPhoto.urls,
                                 isFavorite: newStatus)
        currentPhoto = updatedPhoto
        onPhotoChanged?(currentPhoto)
        NotificationCenter.default.post(name: .favoriteChanged, object: nil, userInfo: ["photoId": currentPhoto.id, "isFavorite": updatedPhoto.isFavorite])
        
    }
}

