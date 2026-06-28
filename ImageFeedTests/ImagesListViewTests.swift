@testable import ImageFeed
import XCTest

private extension Photo {
    static func makeMock(
        id: String = "test-photo-\(UUID().uuidString.prefix(8))",
        width: CGFloat = 1000,
        height: CGFloat = 800,
        createdAt: Date? = nil,
        description: String? = nil,
        isLiked: Bool = false,
        thumbImageURL: String = "https://example.com/thumb.jpg",
        largeImageURL: String = "https://example.com/large.jpg",
        fullImageURL: String = "https://example.com/full.jpg"
    ) -> Photo {
        let size = CGSize(width: width, height: height)
        return Photo(
            id: id,
            size: size,
            createdAt: createdAt,
            description: description,
            thumbImageURL: thumbImageURL,
            largeImageURL: largeImageURL,
            fullImageURL: fullImageURL,
            isLiked: isLiked
        )
    }
}

final class ImagesListViewTests: XCTestCase {
    
    class MockImagesListService: ImagesListServiceProtocol {
        var fetchPhotosNextPageCalled = false
        var photos: [Photo] = []
        
        func fetchPhotosNextPage() {
            fetchPhotosNextPageCalled = true
        }
        
        func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        }
    }

    class MockImagesListServiceWithPhotos: ImagesListServiceProtocol {
        private let photoCount: Int
        var photos: [Photo]
        var fetchPhotosNextPageCalled = false
        
        init(count: Int) {
            self.photoCount = count
            self.photos = Array(repeating: Photo.makeMock(), count: count)
        }
        
        func fetchPhotosNextPage() {
            fetchPhotosNextPageCalled = true
            photos.append(contentsOf: Array(repeating: Photo.makeMock(), count: 3))
        }
        
        func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
            completion(.success(()))
        }
    }
    
    class MockImagesListServiceWithLikes: ImagesListServiceProtocol {
        var lastLikedPhotoId: String?
        var lastIsLikeValue: Bool = false
        var changeLikeCalled = false
        var photos: [Photo] = []
        
        func fetchPhotosNextPage() {}
        
        func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
            lastLikedPhotoId = photoId
            lastIsLikeValue = isLike
            changeLikeCalled = true
            completion(.success(()))
        }
    }
    
    //spy
    class UITableViewSpy: UITableView {
        var reloadDataCalled = false
        
        override func reloadData() {
            reloadDataCalled = true
        }
    }
    
    func testFetchPhotosNextPage() {
        // given
        let mockImagesListService = MockImagesListService()
     
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController else {
            XCTFail("Не удалось загрузить ImagesListViewController из Storyboard")
            return
        }
        
        viewController.configure(mockImagesListService)
        
        //when
        viewController.loadViewIfNeeded()
        _ = viewController.view
        
        //then
        XCTAssertTrue(mockImagesListService.fetchPhotosNextPageCalled)
    }
    
    func testNotification() {
        
        let mockImagesListService = MockImagesListServiceWithPhotos(count: 5)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(
                withIdentifier: "ImagesListViewController"
            ) as? ImagesListViewController else {
                XCTFail("Не удалось загрузить контроллер")
                return
            }

        viewController.configure(mockImagesListService)
            viewController.loadViewIfNeeded()

            guard let tableView = viewController.tableView else {
                XCTFail("tableView является nil")
                return
            }
        
        let tableViewSpy = UITableViewSpy()
        viewController.tableView = tableViewSpy
        
        let notification = Notification(name: ImagesListService.didChangeNotification)
        
        // When
        NotificationCenter.default.post(notification)
        
        // Then
        XCTAssertTrue(tableViewSpy.reloadDataCalled)
    }
    
    // тест лайка
    
    func testDidTapLike() {
        // given
        let mockImagesListService = MockImagesListServiceWithLikes()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
           guard let viewController = storyboard.instantiateViewController(
               withIdentifier: "ImagesListViewController"
           ) as? ImagesListViewController else {
               XCTFail("Не удалось загрузить контроллер")
               return
           }
        
        viewController.configure(mockImagesListService)
        viewController.loadViewIfNeeded()
    
        guard let tableView = viewController.tableView else {
                XCTFail("tableView is nil")
                return
            }
        
        let indexPath = IndexPath(row: 0, section: 0)
           let testPhoto = Photo.makeMock(id: "test-photo-id")
           mockImagesListService.photos = [testPhoto]
        
        tableView.reloadData()
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else {
                XCTFail("Не удалось получить ячейку")
                return
            }

        cell.configure(with: testPhoto, at: indexPath, dateString: "Test Date")
        
        //when
        
        viewController.imageListCellDidTapLike(cell)
        
        // then
        XCTAssertEqual(mockImagesListService.lastLikedPhotoId, "test-photo-id")
        XCTAssertTrue(mockImagesListService.lastIsLikeValue)
        XCTAssertTrue(mockImagesListService.changeLikeCalled)
    }
    
    // тест ячейки
    
    func testHeightForRow() {
        // given
        let mockImagesListService = MockImagesListServiceWithPhotos(count: 1)
        let viewController = ImagesListViewController(imagesListService: mockImagesListService)
        
        let tableView = UITableView()
        
        tableView.frame = CGRect(x: 0, y: 0, width: 375, height: 600)
        
        viewController.tableView = tableView
        
        let indexPath = IndexPath(row: 0, section: 0)
        let photo = mockImagesListService.photos[0]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.frame.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let expectedHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        
        // when
        let actualHeight = viewController.tableView(tableView,
            heightForRowAt: indexPath)
        
        XCTAssertEqual(actualHeight, expectedHeight,
                       accuracy: 0.1)
    }
}
