import Foundation

protocol FetchPhotoRepository: AnyObject {
    func fetchPhotos(page: Int, perPage: Int) async throws -> [Photo]
}
