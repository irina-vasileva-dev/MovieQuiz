import Foundation

struct MoviesLoader: MoviesLoading {
    
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting
    
    // MARK: - Custom Errors
    private enum MoviesLoaderError: Error, LocalizedError {
        case invalidURL
        case networkError(String)
        case decodingError
        case serverError(Int)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Невозможно загрузить данные. Проверьте адрес сервера."
            case .networkError(let message):
                return "Ошибка сети: \(message)"
            case .decodingError:
                return "Не удалось обработать данные с сервера."
            case .serverError(let code):
                return "Ошибка сервера: \(code)"
            }
        }
    }

    // MARK: - init NetworkClient
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL? {
        URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf")
    }
    
    // MARK: - public methods
    func loadMovies(
        handler: @escaping (Result<MostPopularMovies, Error>) -> Void
    ) {
        guard let url = mostPopularMoviesUrl else {
            handler(.failure(MoviesLoaderError.invalidURL))
            return
        }
        
        networkClient.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(
                        MostPopularMovies.self,
                        from: data
                    )
                    
                    guard !mostPopularMovies.items.isEmpty else {
                        handler(.failure(MoviesLoaderError.decodingError))
                        return
                    }
                    
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(MoviesLoaderError.decodingError))
                }
                
            case .failure(let error):
                let loaderError: MoviesLoaderError
                
                if let urlError = error as? URLError {
                    loaderError = .networkError(urlError.localizedDescription)
                } else {
                    loaderError = .networkError(error.localizedDescription)
                }
                
                handler(.failure(loaderError))
            }
        }
    }
}
