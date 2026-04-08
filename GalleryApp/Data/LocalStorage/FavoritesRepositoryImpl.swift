import Foundation
import CoreData

class FavoritesRepositoryImpl: FavoriteRepository {
    private let container: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func add(photoId: String) {
        let context = container.newBackgroundContext()
        context.performAndWait {
            let fetchRequest: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", photoId)
            do {
                let existing = try context.fetch(fetchRequest)
                if existing.isEmpty {
                    let newFavorite = FavoritePhoto(context: context)
                    newFavorite.id = photoId
                    try context.save()
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func remove(photoId: String) {
        let context = container.newBackgroundContext()
        context.performAndWait {
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
        return (try? context.fetch(fetchRequest).map { $0.id! }) ?? []
    }
}
