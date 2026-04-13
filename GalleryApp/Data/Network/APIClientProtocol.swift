import Foundation

protocol APIClientProtocol {
    func fetchPhotos(page: Int, perPage: Int) async throws -> [PhotoResponse]
}
