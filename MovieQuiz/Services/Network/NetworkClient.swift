import Foundation

struct NetworkClient: NetworkRouting {

    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(
            with: request
        ) { data, response, error in
            if let error {
                handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               !(200...299 ~= response.statusCode) {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            guard let data else { return }
            handler(.success(data))
        }
        
        task.resume()
    }
}
