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
        let isFav = repository.isFavorite(photoId: photo.id)
        
        do {
            if isFav {
                try repository.remove(photoId: photo.id)
            } else {
                try repository.add(photo: photo)
            }
        } catch {
            print("Failed to save to Core Data: \(error)")
            return isFav
        }
        
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .favoriteChanged,
                    object: nil,
                    userInfo: ["photoId": photo.id, "isFavorite": !isFav]
                )
            }
        }
        
        return !isFav
    }
}
