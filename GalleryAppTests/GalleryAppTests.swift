//
//  GalleryAppTests.swift
//  GalleryAppTests
//
//  Created by admin on 14.04.26.
//

import Testing
@testable import GalleryApp
import Foundation

class MockFavoriteRepository: FavoriteRepository {
    private var favorites: [String: Photo] = [:]
    
    func add(photo: Photo) throws {
        guard favorites[photo.id] == nil else {
            throw DatabaseError.alreadyExists
        }
        favorites[photo.id] = photo
    }
    
    func remove(photoId: String) throws {
        guard favorites[photoId] != nil else {
            throw DatabaseError.notFound
        }
        favorites[photoId] = nil
    }
    
    func isFavorite(photoId: String) -> Bool {
        return favorites[photoId] != nil
    }
    
    func getAllFavorites() -> [String] {
        return Array(favorites.keys)
    }
    
    func getAllFavoritePhotos() -> [Photo] {
        return Array(favorites.values)
    }
}

struct ToggleFavoriteUseCaseTests {
    
    @Test("Toggle favorite adds photo when not favorite")
    func testToggleFavoriteAddsPhoto() throws {
        let mockRepo = MockFavoriteRepository()
        let useCase = ToggleFavoriteUseCaseImpl(repository: mockRepo)
        let photo = createTestPhoto(id: "test1")
        
        let result = useCase.execute(photo: photo)
        
        #expect(result == true, "Should return true (photo became favorite)")
        #expect(mockRepo.isFavorite(photoId: "test1") == true, "Photo should be in favorites")
    }
    
    @Test("Toggle favorite removes photo when already favorite")
    func testToggleFavoriteRemovesPhoto() throws {
        let mockRepo = MockFavoriteRepository()
        let useCase = ToggleFavoriteUseCaseImpl(repository: mockRepo)
        let photo = createTestPhoto(id: "test2")
        
        let firstResult = useCase.execute(photo: photo)
        let secondResult = useCase.execute(photo: photo)
        
        #expect(firstResult == true, "First toggle should return true")
        #expect(secondResult == false, "Second toggle should return false")
        #expect(mockRepo.isFavorite(photoId: "test2") == false, "Photo should not be in favorites after second toggle")
    }
    
    private func createTestPhoto(id: String) -> Photo {
        let thumbURL = URL(string: "https://example.com/thumb.jpg")!
        let fullURL = URL(string: "https://example.com/full.jpg")!
        let urls = PhotoURLs(thumb: thumbURL, full: fullURL)
        return Photo(
            id: id,
            title: "Test Photo",
            description: "Test Description",
            urls: urls,
            isFavorite: false
        )
    }
}
