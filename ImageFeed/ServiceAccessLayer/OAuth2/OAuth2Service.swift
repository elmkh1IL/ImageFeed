import Foundation

enum NetworkError: Error {
    case invalidRequest
    case httpStatusCode(Int)
    case unknownHTTPResponse
    case decodingError(Error)
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct OAuthTokenResponseBody: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
    }
}

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    private let dataStorage = OAuth2TokenStorage.shared
    private let jsonDecoder = JSONDecoder()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private(set) var authToken: String? {
        get {
            return dataStorage.token
        }
        set {
            dataStorage.token = newValue
        }
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code

        guard
            let request = makeOAuthTokenRequest(code: code)
        else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidRequest))
            }
            print("Не удалось создать URLRequest для получения OAuth token")
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let (data, response)):
                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.unknownHTTPResponse))
                    }
                    return
                }
                
                let statusCode = httpResponse.statusCode
                
                guard 200..<300 ~= statusCode else {
                    let errorBody = String(data: data, encoding: .utf8) ?? "Не удалось прочитать тело ответа"
                    print("Ошибка Unsplash. Код: \(statusCode)")
                    print("Тело ответа: \(errorBody)")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.httpStatusCode(statusCode)))
                    }
                    return
                }
                
                do {
                    let responseBody = try self.jsonDecoder.decode(OAuthTokenResponseBody.self, from: data)
                    OAuth2TokenStorage.shared.token = responseBody.accessToken
                    DispatchQueue.main.async {
                        completion(.success(responseBody.accessToken))
                    }
                } catch {
                    print("Ошибка декодирования OAuthTokenResponseBody: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.decodingError(error)))
                    }
                }
                
            case .failure(let error):
                print("Сетевая ошибка: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }

private func makeOAuthTokenRequest(code: String) -> URLRequest? {
    guard
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
    else {
        return nil
    }
    
    urlComponents.queryItems = [
        URLQueryItem(name: "client_id", value: Constants.accessKey),
        URLQueryItem(name: "client_secret", value: Constants.secretKey),
        URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
        URLQueryItem(name: "code", value: code),
        URLQueryItem(name: "grant_type", value: "authorization_code"),
    ]
    
    guard let authTokenUrl = urlComponents.url else {
        return nil
    }
    
    var request = URLRequest(url: authTokenUrl)
    request.httpMethod = HTTPMethod.post.rawValue
    return request
}
    
    private struct OAuthTokenResponseBody: Codable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
}

extension URLSession {
    func data(for request: URLRequest, completionHandler: @escaping (Result<(data: Data, response: URLResponse), Error>) -> Void) -> URLSessionDataTask {
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }

            guard let response = response, let data = data else {
                completionHandler(.failure(URLError(.badServerResponse)))
                return
            }

            completionHandler(.success((data: data, response: response)))
        }
        task.resume()
        return task
    }
}
