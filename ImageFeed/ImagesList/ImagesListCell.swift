import UIKit
import Kingfisher
import Logging

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet private weak var imageCell: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    @IBAction func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    // TODO: убрать ! везде
    
    private let logger = Logger(label: "ImagesListCell")
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    private var currentIndexPath: IndexPath?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageCell.kf.cancelDownloadTask()
        imageCell.image = nil
    }
    
    func configure(with photo: Photo, at indexPath: IndexPath, dateString: String) {
        self.currentIndexPath = indexPath
        setIsLiked(photo.isLiked)
        dateLabel.text = dateString
        imageCell.kf.indicatorType = .activity
        let placeholder = UIImage(resource: .placeholder)
        
        if let thumbnailURL = URL(string: photo.thumbImageURL) {
            imageCell.kf.setImage(
                with: thumbnailURL,
                placeholder: placeholder,
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.2))
                ]
           )
        } else {
            imageCell.image = placeholder
            logger.error("Неверный URL: \(photo.thumbImageURL)")
        }
    }

    func setIsLiked(_ isLiked: Bool) {
        likeButton.setImage(UIImage(resource: isLiked ? .likeActive : .likeNoActive), for: .normal)
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
    func reloadCell(at indexPath: IndexPath)
}
