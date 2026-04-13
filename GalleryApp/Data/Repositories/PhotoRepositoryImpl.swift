import Foundation

class PhotoRepositoryImpl: FetchPhotoRepository {
    private let apiClient: APIClientProtocol
    private let favoriteRepository: FavoriteRepository
    
    init(apiClient: APIClientProtocol, favoriteRepository: FavoriteRepository) {
        self.apiClient = apiClient
        self.favoriteRepository = favoriteRepository
    }
    
    func fetchPhotos(page: Int, perPage: Int) async throws -> [Photo] {
        let responses = try await apiClient.fetchPhotos(page: page, perPage: perPage)
        let favoriteIds = Set(favoriteRepository.getAllFavorites())
        let photos = responses.compactMap { response in
            let isFavorite = favoriteIds.contains(response.id)
            return PhotoMapper.toDomain(from: response, isFavorite: isFavorite)
        }
        return photos
    }
}
