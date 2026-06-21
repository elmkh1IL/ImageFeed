@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    
    //моки протоколов
    class MockProfileService: ProfileServiceProtocol {
        var profile: Profile?
    }
    
    class MockProfileImageService: ProfileImageServiceProtocol {
        var avatarURL: String?
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
        
        func setupViews() {
            setupViewsCalled = true
        }
        
        func updateProfileDetails(profile: Profile) {
            updateProfileDetailsCalled = true
        }
        
        func updateAvatar(with urlString: String?) {
            updateAvatarCalled = true
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
        
        print("Creating view controller...")
        let viewController = ProfileViewController(
            profileService: mockProfileService,
            imageService: mockImageService,
            logoutService: mockLogoutService,
            viewControllerDelegate: spy
        )
        print("View controller created successfully")
        
        
        //when
        viewController.viewDidLoad()
        print("viewDidLoad called")

        
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
        
        let viewController = ProfileViewController(
            profileService: mockProfileService,
            imageService: mockImageService,
            logoutService: mockLogoutService,
            viewControllerDelegate: spy
        )
        
        //when
        viewController.viewDidLoad()
        
        //then
        XCTAssertTrue(spy.updateAvatarCalled)
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
        
        //when
        viewController.exitButton?.sendActions(for: UIControl.Event.touchUpInside)
        
        //then
        XCTAssertTrue(spy.showLogoutAlertCalled)
    }
}
