import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var dataLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    static let reuseIdentifier = "ImagesListCell"
    
}
