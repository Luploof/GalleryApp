import UIKit

protocol ImageLoaderProtocol {
    func loadImage(from url: URL) async throws -> UIImage
}

class ImageLoader: ImageLoaderProtocol {
    private let cache = NSCache<NSString, UIImage>()
    
    func loadImage(from url: URL) async throws -> UIImage {
        let key = url.absoluteString as NSString
        
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw ImageLoadingError.invalidImageData
        }
        cache.setObject(image, forKey: key)
        return image
    }
}
