import Foundation

protocol FetchPhotosUseCase {
    func execute(page: Int, perPage: Int) async throws -> [Photo]
}

class FetchPhotosUseCaseImpl: FetchPhotosUseCase {
    private let repository: FetchPhotoRepository
    
    init(repository: FetchPhotoRepository) {
        self.repository = repository
    }
    
    func execute(page: Int, perPage: Int) async throws -> [Photo] {
        return try await repository.fetchPhotos(page: page, perPage: perPage)
    }
}
