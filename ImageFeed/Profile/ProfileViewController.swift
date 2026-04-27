import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var profileImage: UIImageView!
    private var nameLabel: UILabel!
    private var usernameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var exitButton: UIButton!

    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        setupProfileImage()
        setupNameLabel()
        setupUsernameLabel()
        setupDescriptionLabel()
        setupExitButton()
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func updateAvatar() {
            guard
                let profileImageURL = ProfileImageService.shared.avatarURL,
                let imageURL = URL(string: profileImageURL)
            else { return }
            
           print("imageURL: \(imageURL)")
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImage.kf.indicatorType = .activity
        profileImage.kf.setImage(
            with: imageURL,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]) { result in
                
                switch result {
                case .success(let value):
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
            
            private func setupProfileImage() {
                profileImage = UIImageView()
                profileImage.image = UIImage(resource: .photo)
                profileImage.contentMode = .scaleAspectFill
                view.addSubview(profileImage)
                
                profileImage.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                    profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                    profileImage.widthAnchor.constraint(equalToConstant: 70),
                    profileImage.heightAnchor.constraint(equalToConstant: 70),
                ])
            }
            
            private func setupNameLabel(){
                nameLabel = UILabel()
                nameLabel.text = "Екатерина Новикова"
                nameLabel.font = UIFont.systemFont(ofSize: 23.0, weight: .bold)
                nameLabel.textAlignment = .left
                nameLabel.textColor = UIColor(resource: .ypWhite)
                view.addSubview(nameLabel)
                
                nameLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                    nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
                ])
            }
            
            private func setupUsernameLabel() {
                usernameLabel = UILabel()
                usernameLabel.text = "@ekaterina_nov"
                usernameLabel.font = UIFont.systemFont(ofSize: 13.0)
                usernameLabel.textAlignment = .left
                usernameLabel.textColor = UIColor(resource: .ypGray)
                view.addSubview(usernameLabel)
                
                usernameLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    usernameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                    usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
                ])
            }
            
            private func setupDescriptionLabel() {
                descriptionLabel = UILabel()
                descriptionLabel.text = "Hello, world!"
                descriptionLabel.font = UIFont.systemFont(ofSize: 13.0)
                descriptionLabel.textAlignment = .left
                descriptionLabel.textColor = UIColor(resource: .ypWhite)
                view.addSubview(descriptionLabel)
                
                descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                    descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
                ])
            }
            
            private func setupExitButton() {
                exitButton = UIButton()
                exitButton.setImage(UIImage(named: "Exit"), for: .normal)
                exitButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
                view.addSubview(exitButton)
                
                exitButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                    exitButton.topAnchor.constraint(equalTo: profileImage.topAnchor),
                    exitButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
                    exitButton.widthAnchor.constraint(equalToConstant: 44),
                    exitButton.heightAnchor.constraint(equalToConstant: 44)
                ])
            }
            
            private func updateProfileDetails(profile: Profile) {
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
                
            }
}
