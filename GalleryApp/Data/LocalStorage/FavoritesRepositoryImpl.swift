import Foundation
import CoreData

class FavoritesRepositoryImpl: FavoriteRepository {
    private let container: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func add(photo: Photo) throws {
        try container.viewContext.performAndWait {
            let fetchRequest: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", photo.id)
            
            do {
                let existing = try container.viewContext.fetch(fetchRequest)
                if existing.isEmpty {
                    let newFavorite = FavoritePhoto(context: container.viewContext)
                    newFavorite.id = photo.id
                    newFavorite.title = photo.title
                    newFavorite.descriptionPhoto = photo.description
                    newFavorite.full = photo.urls.full.absoluteString
                    newFavorite.thumb = photo.urls.thumb.absoluteString
                    try container.viewContext.save()
                } else {
                    throw DatabaseError.alreadyExists
                }
            } catch {
                throw  DatabaseError.saveFailed(underlyingError: error)
            }
        }
    }
    
    func remove(photoId: String) throws {        
        try container.viewContext.performAndWait {
            let fetchRequest: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", photoId)
            
            do {
                let existing = try container.viewContext.fetch(fetchRequest)
                if let object = existing.first {
                    container.viewContext.delete(object)
                    try container.viewContext.save()
                } else {
                   throw DatabaseError.notFound
                }
            } catch {
                throw DatabaseError.deleteFailed(underlyingError: error)
            }
        }
        
    }
    
    func isFavorite(photoId: String) -> Bool {
        let fetchRequest: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", photoId)
        return (try? container.viewContext.count(for: fetchRequest)) ?? 0 > 0
    }
    
    func getAllFavorites() -> [String] {
        let fetchRequest: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
        fetchRequest.propertiesToFetch = ["id"]
        return (try? container.viewContext.fetch(fetchRequest).map { $0.id }) ?? []
    }
    
    func getAllFavoritePhotos() -> [Photo] {
        let fetchRequest: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
        
        do {
            let items = try container.viewContext.fetch(fetchRequest)
            let photos = items.compactMap { item -> Photo? in
                guard let thumbURL = URL(string: item.thumb),
                      let fullURL = URL(string: item.full) else {
                    return nil
                }
                let urls = PhotoURLs(thumb: thumbURL, full: fullURL)
                
                return Photo(
                    id: item.id,
                    title: item.title,
                    description: item.descriptionPhoto,
                    urls: urls,
                    isFavorite: true
                )
            }
            return photos
        } catch {
            print("Database error in getAllFavoritePhotos: \(error)")
            return []
        }
    }
}
