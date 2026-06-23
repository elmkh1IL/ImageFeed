@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    
    //моки протоколов
    class MockProfileService: ProfileServiceProtocol {
        var profile: Profile?
    }
    
    class MockProfileImageService: ProfileImageServiceProtocol {
        var avatarURL: String?
        var delegate: ProfileImageServiceDelegate?
            }
    
    class MockProfileLogoutService: ProfileLogoutServiceProtocol {
        var logoutCalled = false
        func logout() {
            logoutCalled = true
        }
    }
    
    // шпион
    private class ProfileViewControllerSpy: ProfileViewControllerProtocol {
        var setupViewsCalled = false
        var updateProfileDetailsCalled = false
        var updateAvatarCalled = false
        var showLogoutAlertCalled = false
        
        var lastUpdateAvatarURL: String?
        
        func setupViews() {
            setupViewsCalled = true
        }
        
        func updateProfileDetails(profile: Profile) {
            updateProfileDetailsCalled = true
        }
        
        func updateAvatar(with urlString: String?) {
            updateAvatarCalled = true
            lastUpdateAvatarURL = urlString
        }
        
        func showLogoutAlert() {
            showLogoutAlertCalled = true
        }
    }
    
    //1 - проверка что setupViews() вызывается при загрузке viewDidLoad
    
    func testViewDidLoadCallsSetupViews() {
        
        // given
        let mockProfileService = MockProfileService()
        let mockImageService = MockProfileImageService()
        let mockLogoutService = MockProfileLogoutService()
        let spy = ProfileViewControllerSpy()
        mockImageService.avatarURL = "https://example.com/avatar.jpg"
        
        let viewController = ProfileViewController(
            profileService: mockProfileService,
            imageService: mockImageService,
            logoutService: mockLogoutService,
            viewControllerDelegate: spy
        )
        
        //when
        viewController.viewDidLoad()

        //then
        XCTAssertTrue(spy.setupViewsCalled)
    }
    
    //2 - проверка обновления данных профиля
    
    func testUpdateProfileDetails() {
        
        // given
        let mockProfileService = MockProfileService()
        let mockImageService = MockProfileImageService()
        let mockLogoutService = MockProfileLogoutService()
        let spy = ProfileViewControllerSpy()
        let profile = Profile(username: "новый юзернейм", name: "Новое имя", loginName: "@юзернейм", bio: "новое био")
        mockProfileService.profile = profile
        
        let viewController = ProfileViewController(
            profileService: mockProfileService,
            imageService: mockImageService,
            logoutService: mockLogoutService,
            viewControllerDelegate: spy
        )
        
        //when
        viewController.setupViews()
        viewController.viewDidLoad()
        
        //then
        XCTAssertTrue(spy.updateProfileDetailsCalled)
    }
    
    // 3 - проверка загрузки аватарки
    
    func testUpdateAvatar() {
        
        // given
        let mockProfileService = MockProfileService()
        let mockImageService = MockProfileImageService()
        let mockLogoutService = MockProfileLogoutService()
        let spy = ProfileViewControllerSpy()
        let validURL = "https://example.com/avatar.jpg"
        mockImageService.avatarURL = validURL
        
        let viewController = ProfileViewController(
            profileService: mockProfileService,
            imageService: mockImageService,
            logoutService: mockLogoutService,
            viewControllerDelegate: spy
        )
        
        //when
        viewController.loadViewIfNeeded()
        viewController.view.layoutIfNeeded()
        viewController.viewDidLoad()
        
        usleep(100000)
        
        viewController.updateAvatar(with: validURL)
        
        usleep(100000)
        //then
        XCTAssertEqual(spy.lastUpdateAvatarURL, validURL)
    }
    
    // 4 - проверка выхода и показа алерта
    
    func testExitButtonCallsShowLogoutAlert() {
        
        // given
        let mockProfileService = MockProfileService()
        let mockImageService = MockProfileImageService()
        let mockLogoutService = MockProfileLogoutService()
        let spy = ProfileViewControllerSpy()
        
        let viewController = ProfileViewController(
            profileService: mockProfileService,
            imageService: mockImageService,
            logoutService: mockLogoutService,
            viewControllerDelegate: spy
        )
        viewController.loadViewIfNeeded()
        viewController.view.layoutIfNeeded()
        viewController.viewDidLoad()
        
        usleep(100000) // Задержка в 100 мс
        
        XCTAssertNotNil(viewController.exitButton, "exitButton должен быть создан")
        
        //when
        viewController.exitButton?.sendActions(for: UIControl.Event.touchUpInside)
        
        //then
        XCTAssertTrue(spy.showLogoutAlertCalled)
    }
}
