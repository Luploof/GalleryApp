import Foundation
import CoreData

@objc(FavoritePhoto)
public class FavoritePhoto: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var thumb: String
    @NSManaged public var full: String
    @NSManaged public var title: String?
    @NSManaged public var descriptionPhoto: String?
}

extension FavoritePhoto {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritePhoto> {
        return NSFetchRequest<FavoritePhoto>(entityName: "FavoritePhoto")
    }
}
