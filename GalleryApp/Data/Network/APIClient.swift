import Foundation

class APIClient: APIClientProtocol {
    let baseURL = "https://api.unsplash.com"
    let apiKey: String
    
    init() throws(NetworkError) {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path) as? [String: Any],
              let key = config["UnsplashAccessKey"] as? String else {
            throw NetworkError.missingAPIKey
        }
        self.apiKey = key
    }
    
    func fetchPhotos(page: Int, perPage: Int) async throws(NetworkError) -> [PhotoResponse] {
        let endpoint = "https://api.unsplash.com/photos?page=\(page)&per_page=\(perPage)"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Authorization": "Client-ID \(apiKey)"]
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse(statusCode: -1)
            }
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    return try decoder.decode([PhotoResponse].self, from: data)
                } catch {
                    throw NetworkError.decodingFailed(underlyingError: error)
                }
            case 401:
                throw NetworkError.unauthorized
            case 429:
                let retryAfter = httpResponse.allHeaderFields["Retry-After"] as? Int ?? 60
                throw NetworkError.rateLimitExceeded(retryAfter: retryAfter)
            default:
                throw NetworkError.invalidResponse(statusCode: httpResponse.statusCode)
            }
        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                throw NetworkError.noInternetConnection
            } else {
                throw NetworkError.unknown(underlyingError: urlError)
            }
        } catch {
            throw NetworkError.unknown(underlyingError: error)
        }
    }
}
