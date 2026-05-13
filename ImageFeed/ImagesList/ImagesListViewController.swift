import UIKit
import Logging
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    private let logger = Logger(label: "ImagesListViewController")
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    var photos: [Photo] = []
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let imagesListService = ImagesListService()
    private var notificationObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        setupTableView()
        setupNotifications()
        imagesListService.fetchPhotosNextPage()
    }
    
    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            UINib(nibName: "ImageListCell", bundle: nil),
            forCellReuseIdentifier: "ImageListCell"
        )
    }
    
    private func setupNotifications() {
        notificationObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
    }
    
    private func updateTableViewAnimated() {
        let oldPhotos = photos
        photos = imagesListService.photos
        
        let oldCount = oldPhotos.count
        let newCount = photos.count
        
        tableView.performBatchUpdates({
            var indexPathsToDelete: [IndexPath] = []
            var indexPathsToInsert: [IndexPath] = []
            
            // Удаляю лишние строки, если их стало меньше
            if newCount < oldCount {
                indexPathsToDelete = (newCount..<oldCount).map { IndexPath(row: $0, section: 0)}
            }
            
            // Если строк стало больше, добавляю
            if newCount > oldCount {
                indexPathsToInsert = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                
            }
            
            if !indexPathsToDelete.isEmpty {
                tableView.deleteRows(at: indexPathsToDelete, with: .automatic)
            }
            if !indexPathsToInsert.isEmpty {
                tableView.insertRows(at: indexPathsToInsert, with: .automatic)
            }
        }) { _ in
            print("Таблица обновлена: было \(oldCount), стало \(newCount) элементов")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSingleImage" {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Недопустимый пункт назначения перехода(segue)")
                return
            }
            guard indexPath.row < photos.count else { return }
            let photo = photos[indexPath.row]
            
            if let fullImageURL = URL(string: photo.fullImageURL) {
                viewController.imageURL = fullImageURL
            } else {
                let placeholder = UIImage(resource: .placeholder)
                viewController.image = placeholder
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func showErrorAlert(message: String) {
        let alertController = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            assertionFailure("Не удалось создать ячейку ImageListCell")
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        
        let dateString: String
        if let createdAt = photo.createdAt {
            dateString = dateFormatter.string(from: createdAt)
        } else {
            dateString = "Дата неизвестна"
        }
        cell.delegate = self
        cell.configure(with: photo, at: indexPath, dateString: dateString)
        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard indexPath.row < photos.count else { return 0 }
        let photo = photos[indexPath.row]
        
        let imageSize = photo.size
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.frame.width - imageInsets.left - imageInsets.right
        
        let scale = imageViewWidth / imageSize.width
        let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              indexPath.row < photos.count else { return }
        
        let photo = photos[indexPath.row]
        let currentIsLiked = photo.isLiked
        
        // Сразу обновляем интерфейс
        cell.setIsLiked(!currentIsLiked)
        
        UIBlockingProgressHUD.show()
        tableView.isUserInteractionEnabled = false
        
        imagesListService.changeLike(photoId: photo.id, isLike: !currentIsLiked) { result in
            DispatchQueue.main.async {
                self.tableView.isUserInteractionEnabled = true
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success:
                    print("Лайк успешно изменён для фото \(photo.id)")
                    self.photos = self.imagesListService.photos
                    if let updateCell = self.tableView.cellForRow(at: indexPath) as? ImagesListCell {
                        updateCell.setIsLiked(self.photos[indexPath.row].isLiked)
                    }
                case .failure(let error):
                    print("Ошибка при изменении лайка: \(error)")
                    cell.setIsLiked(currentIsLiked)
                    self.showErrorAlert(message: "Не удалось изменить лайк")
                }
            }
        }
    }
    
    func reloadCell(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
