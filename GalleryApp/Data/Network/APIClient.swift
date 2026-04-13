import Foundation

class APIClient: APIClientProtocol {
    let baseURL = "https://api.unsplash.com"
    let apiKey: String
    
    init() {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path) as? [String: Any],
              let key = config["UnsplashAccessKey"] as? String else {
            fatalError("Config.plist not found or missing UnsplashAccessKey")
        }
        self.apiKey = key
    }
    
    func fetchPhotos(page: Int, perPage: Int) async throws -> [PhotoResponse] {
        let endpoint = "https://api.unsplash.com/photos?page=\(page)&per_page=\(perPage)"
        guard let url = URL(string: endpoint) else {
            throw NSError(domain: "NetworkError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Uncorrect URL"])
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Authorization": "Client-ID \(apiKey)"]
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NSError(domain: "NetworkError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Uncorrectresponse"])
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([PhotoResponse].self, from: data)
    }
}
