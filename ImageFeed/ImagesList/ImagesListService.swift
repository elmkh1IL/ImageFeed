import Foundation
import Kingfisher
import CoreGraphics
import Logging

struct PhotoResult: Codable {
    let id: String
    let createdAt: Date?
    let updatedAt: Date?
    let width: Int
    let height: Int
    let color: String?
    let blurHash: String?
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, color, likes, urls, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case blurHash = "blur_hash"
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let description: String?
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageURL: String
    let isLiked: Bool
}

extension Photo {
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = result.createdAt
        self.description = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.regular
        self.fullImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var copy = self
        copy[index] = newValue
        return copy
    }
}

final class ImagesListService: ImagesListServiceProtocol {
    static let shared = ImagesListService()
    let accessKey = Constants.accessKey
    private let logger = Logger(label: "ImagesListService")
    private(set) var photos: [Photo] = []
    
    private let decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return decoder
        }()
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private var lastLoadedPage: Int?
    private var isLoading = false
    private let urlSession = URLSession.shared
    
    // функция отвечает за сетевой запрос и ответ
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        print("changeLike вызван для photoId: \(photoId), isLike: \(isLike)")
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        
        guard let token = OAuth2Service.shared.authToken else {
            completion(.failure(NSError(domain: "Unauthorized", code: 401)))
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            
            if let error {
                print("Сетевая ошибка: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "No HTTP response", code: 0)))
                return
            }
            
            print("like status:", httpResponse.statusCode, "body:", String(data: data ?? Data(), encoding: .utf8) ?? "nil")
            
            DispatchQueue.main.async {
                if (200...299).contains(httpResponse.statusCode) {
                    self.updatePhotoLikeStatus(photoId: photoId)
                    completion(.success(()))
                } else {
                    let error = NSError(domain: "HTTP error", code: httpResponse.statusCode, userInfo: nil)
                    completion(.failure(error))
                }
            }
        }
        print("Запущен dataTask")
        task.resume()
    }
    
    // отвечает за обнову модели и отправку уведомления
    private func updatePhotoLikeStatus(photoId: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard let index = self.photos.firstIndex(where: { $0.id == photoId }) else {
                logger.warning("Предупреждение: Фото с ID \(photoId) не найдено в массиве с фото")
                return
            }
            
            let photo = self.photos[index]
            let newPhoto = Photo(
                id: photo.id,
                size: photo.size,
                createdAt: photo.createdAt,
                description: photo.description,
                thumbImageURL: photo.thumbImageURL,
                largeImageURL: photo.largeImageURL,
                fullImageURL: photo.fullImageURL,
                isLiked: !photo.isLiked
            )
            
            self.photos[index] = newPhoto
            
            //уведомление на всякий случай об измненении
            NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: self
            )
        }
    }
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        
        isLoading = true
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        lastLoadedPage = nextPage
        
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=20&client_id=\(accessKey)") else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            
            defer {
                self.isLoading = false
            }
            
            if let error = error {
                logger.error("Ошибка при выборе фотографий: \(error)")
                return
            }
            
            guard let data = data else {
                logger.error("Нет данных")
                return
            }
            
            do {
                let photoResults = try self.decoder.decode([PhotoResult].self, from: data)
                
                let newPhotos = photoResults.map { Photo(from: $0) }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            } catch {
                logger.error("Ошибка при декодировании JSON: \(error)")
            }
        }
        task.resume()
    }
    
    func reset() {
        photos.removeAll()
        lastLoadedPage = nil
        isLoading = false
    }
    
    func clearCache() {
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
        photos.removeAll()
    }
}
