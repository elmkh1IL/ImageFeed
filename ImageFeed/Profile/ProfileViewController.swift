import UIKit
import Kingfisher
import Logging

enum SystemImage: String {
    case personCircleFill = "person.circle.fill"
}

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
}

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
}

protocol ProfileLogoutServiceProtocol {
    func logout()
}

protocol ProfileViewControllerProtocol: AnyObject {
    func setupViews()
    func updateProfileDetails(profile: Profile)
    func updateAvatar(with urlString: String?)
    func showLogoutAlert()
}


final class ProfileViewController: UIViewController, ProfileImageServiceDelegate, ProfileViewControllerProtocol {
    
    private let logger = Logger(label: "ProfileViewController")
    
    // зависимости
    private let profileService: ProfileServiceProtocol
    private let imageService: ProfileImageServiceProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    
    init(
           profileService: ProfileServiceProtocol = ProfileService.shared,
           imageService: ProfileImageServiceProtocol = ProfileImageService.shared,
           logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
       ) {
           self.profileService = profileService
           self.imageService = imageService
           self.logoutService = logoutService
           super.init(nibName: nil, bundle: nil)
       }
    
    required init?(coder: NSCoder) {
          // TODO: заменить фатал еррор
        fatalError("init(coder:) has not been implemented")
       }
    
    private var profileImage: UIImageView?
    private var nameLabel: UILabel?
    private var usernameLabel: UILabel?
    private var descriptionLabel: UILabel?
    var exitButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .ypBlack)
        setupViews()
        
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        
        if let imageService = imageService as? ProfileImageService {
            imageService.delegate = self
        } else {
            logger.warning("Внимание: imageService не соотвествует требованиям")
        }
        updateAvatar(with: imageService.avatarURL)
        
    }
    
    func setupViews() {
        
        setupProfileImage()
        setupNameLabel()
        setupUsernameLabel()
        setupDescriptionLabel()
        setupExitButton()
    }
    
    func updateAvatar(with urlString: String?) {
        guard
            let profileImageURL = urlString,
            let imageURL = URL(string: profileImageURL),
            let profileImageView = profileImage
        else { return }
        
        print("imageURL: \(imageURL)")
        
        let options = configureImage()
        
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(
            with: imageURL,
            placeholder: options.placeholder,
            options: options.options
        ) { [weak self] result in
            guard let self else { return }
        }
    }
    
    private func configureImage() -> (placeholder: UIImage?, options: [KingfisherOptionsInfoItem]) {
            let placeholderImage = UIImage(systemName: SystemImage.personCircleFill.rawValue)?
                .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
            
            let processor = RoundCornerImageProcessor(cornerRadius: 35)
            
            let options: [KingfisherOptionsInfoItem] = [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]
            return (placeholderImage, options)
        }
        
        private func imageLoadResult (_ result: Result<RetrieveImageResult, KingfisherError>) {
            switch result {
            case .success(let value):
                print(value.image)
                print(value.cacheType)
                print(value.source)
                
            case .failure:
                logger.error("Ошибка загрузки изображения")
            }
        }
    
    private func setupProfileImage() {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .photo)
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        profileImage = imageView
    }
    
    private func setupNameLabel(){
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23.0, weight: .bold)
        label.textAlignment = .left
        label.textColor = UIColor(resource: .ypWhite)
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: profileImage?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
        
        nameLabel = label
    }
    
    private func setupUsernameLabel() {
        let username = UILabel()
        username.text = "@ekaterina_nov"
        username.font = UIFont.systemFont(ofSize: 13.0)
        username.textAlignment = .left
        username.textColor = UIColor(resource: .ypGray)
        view.addSubview(username)
        
        username.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            username.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            username.topAnchor.constraint(equalTo: nameLabel?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
        
        usernameLabel = username
    }
    
    private func setupDescriptionLabel() {
        let description = UILabel()
        description.text = "Hello, world!"
        description.font = UIFont.systemFont(ofSize: 13.0)
        description.textAlignment = .left
        description.textColor = UIColor(resource: .ypWhite)
        view.addSubview(description)
        
        description.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            description.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            description.topAnchor.constraint(equalTo: usernameLabel?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
        
        descriptionLabel = description
    }
    
    private func setupExitButton() {
        let exit = UIButton()
        exit.setImage(UIImage(resource: .exit), for: .normal)
        exit.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        view.addSubview(exit)
        
        exit.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            exit.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exit.topAnchor.constraint(equalTo: profileImage?.topAnchor ?? view.safeAreaLayoutGuide.topAnchor),
            exit.centerYAnchor.constraint(equalTo: profileImage?.centerYAnchor ?? view.centerYAnchor),
            exit.widthAnchor.constraint(equalToConstant: 44),
            exit.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        exitButton = exit
    }
    
    func updateProfileDetails(profile: Profile) {
        guard let nameLabel = nameLabel,
              let usernameLabel = usernameLabel,
              let descriptionLabel = descriptionLabel
        else {
            logger.error("Какие-то элементы = nil")
            return
        }
        nameLabel.text = profile.name.isEmpty
        ? "Имя не указано"
        : profile.name
        usernameLabel.text = profile.loginName.isEmpty
        ? "@неизвестный_пользователь"
        : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true)
        ? "Профиль не заполнен"
        : profile.bio
    }
    
    func profileImageService(_ service: ProfileImageService, didUpdateAvatarURL url: String?) {
        updateAvatar(with: url)
    }
    
    @objc private func didTapButton() {
     showLogoutAlert()
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
        let logoutAction = UIAlertAction(title: "Да", style: .default) { _ in
            self.logoutService.logout()
        }
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        present(alert, animated: true)
    }
    
    deinit {
        (imageService as? ProfileImageService)?.delegate = nil
    }
}
