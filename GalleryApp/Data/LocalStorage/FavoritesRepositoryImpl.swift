import Foundation
import CoreData

class FavoritesRepositoryImpl: FavoriteRepository {
    private let container: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func add(photo: Photo) {
        container.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", photo.id)
            do {
                let existing = try context.fetch(fetchRequest)
                if existing.isEmpty {
                    let newFavorite = FavoritePhoto(context: context)
                    newFavorite.id = photo.id
                    newFavorite.title = photo.title
                    newFavorite.descriptionPhoto = photo.description
                    newFavorite.full = photo.urls.full.absoluteString
                    newFavorite.thumb = photo.urls.thumb.absoluteString
                    try context.save()
                }
            } catch {
                print("Error: \(error)")
            }
            
        }
        
    }
    
    func remove(photoId: String) {
        container.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", photoId)
            do {
                let existing = try context.fetch(fetchRequest)
                if let object = existing.first {
                    context.delete(object)
                    try context.save()
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func isFavorite(photoId: String) -> Bool {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", photoId)
        return (try? context.count(for: fetchRequest)) ?? 0 > 0
    }
    
    func getAllFavorites() -> [String] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
        fetchRequest.propertiesToFetch = ["id"]
        return (try? context.fetch(fetchRequest).map { $0.id }) ?? []
    }
    
    func getAllFavoritePhotos() -> [Photo] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
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
            print("Error: \(error)")
            return []
        }
    }
}
