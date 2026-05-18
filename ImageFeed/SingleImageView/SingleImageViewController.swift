import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    var imageURL: URL?
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else {return}
            
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBAction func didTapBackButton() {
        dismiss(animated: true)
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        imageView.contentMode = .scaleAspectFit
        loadImage()
        
        guard let image else {return}
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerImage()
    }
    
    
    private func loadImage() {
        guard let imageURL = imageURL else { return }
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alertController = UIAlertController(
            title: "Ошибка",
            message: "Что-то пошло не так. Попрбовать еще раз?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel)
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { _ in
            self.loadImage()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(retryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        
        imageView.image = image
        let aspectRatio = image.size.width / image.size.height
        let viewWidth = scrollView.bounds.width
        
        var height = viewWidth / aspectRatio
        if height > scrollView.bounds.height {
            height = scrollView.bounds.height
            let width = height * aspectRatio
            imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        } else {
            imageView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: height)
        }
        
        scrollView.contentSize = image.size
        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        
        centerImage()
    }
    
    private func centerImage() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let horizontalPadding = max(0, (scrollViewSize.width - imageViewSize.width) / 2)
        let verticalPadding = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding
        )
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
