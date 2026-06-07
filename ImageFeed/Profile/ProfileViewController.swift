import UIKit
import Kingfisher
import Logging

enum SystemImage: String {
    case personCircleFill = "person.circle.fill"
}

final class ProfileViewController: UIViewController {
    
    private let logger = Logger(label: "ProfileViewController")
    
    private var profileImage: UIImageView?
    private var nameLabel: UILabel?
    private var usernameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var exitButton: UIButton?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .ypBlack)
        setupViews()
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }
        
        updateAvatar()
        
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupViews() {
        
        setupProfileImage()
        setupNameLabel()
        setupUsernameLabel()
        setupDescriptionLabel()
        setupExitButton()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageURL = URL(string: profileImageURL),
            let profileImageView = profileImage
        else { return }
        
        print("imageURL: \(imageURL)")
        
        let placeholderImage = UIImage(systemName: SystemImage.personCircleFill.rawValue)?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(
            with: imageURL,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let value):
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                    
                case .failure:
                    logger.error("Ошибка загрузки изображения")
                }
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
    
    private func updateProfileDetails(profile: Profile) {
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
    
    @objc private func didTapButton() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
        let logoutAction = UIAlertAction(title: "Да", style: .default) { _ in
            ProfileLogoutService.shared.logout()
        }
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        
        present(alert, animated: true)
    }
}
