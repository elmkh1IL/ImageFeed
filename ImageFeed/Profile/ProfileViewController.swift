import UIKit

final class ProfileViewController: UIViewController {
    
    private var profileImage: UIImageView!
    private var nameLabel: UILabel!
    private var usernameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var exitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileImage()
        setupNameLabel()
        setupUsernameLabel()
        setupDescriptionLabel()
        setupExitButton()
    }
    
    private func setupProfileImage() {
        profileImage = UIImageView()
        profileImage.image = UIImage(named: "Photo")
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
        nameLabel.textColor = UIColor(named: "YP White")
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
        usernameLabel.textColor = UIColor(named: "YP Gray")
        view.addSubview(usernameLabel)
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
          usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
                ])
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, word!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13.0)
        descriptionLabel.textAlignment = .left
        descriptionLabel.textColor = UIColor(named: "YP White")
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
        
    @objc private func didTapButton() {
     
    }
}
