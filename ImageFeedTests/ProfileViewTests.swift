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
        
        let viewController = ProfileViewController(
            profileService: mockProfileService,
            imageService: mockImageService,
            logoutService: mockLogoutService
        )
        
        let spy = ProfileViewControllerSpy()
        
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
        
        let viewController = ProfileViewController(
            profileService: mockProfileService,
            imageService: mockImageService,
            logoutService: mockLogoutService
        )
        
        let spy = ProfileViewControllerSpy()
        let profile = Profile(username: "новый юзернейм", name: "Новое имя", loginName: "@юзернейм", bio: "новое био")
        
        //when
        viewController.updateProfileDetails(profile: profile)
        
        //then
        XCTAssertTrue(spy.updateProfileDetailsCalled)
    }
    
    // 3 - проверка загрузки аватарки
    
    func testUpdateAvatar() {
        
        // given
        let mockProfileService = MockProfileService()
        let mockImageService = MockProfileImageService()
        let mockLogoutService = MockProfileLogoutService()
        
        let viewController = ProfileViewController(
            profileService: mockProfileService,
            imageService: mockImageService,
            logoutService: mockLogoutService
        )
        
        let spy = ProfileViewControllerSpy()
        let validURL = "https://example.com/avatar.jpg"
        
        //when
        viewController.updateAvatar(with: validURL)
        
        //then
        XCTAssertTrue(spy.updateAvatarCalled)
    }
    
    // 4 - проверка выхода и показа алерта
    
    func testExitButtonCallsShowLogoutAlert() {
        
        // given
        let mockProfileService = MockProfileService()
        let mockImageService = MockProfileImageService()
        let mockLogoutService = MockProfileLogoutService()
        
        let viewController = ProfileViewController(
            profileService: mockProfileService,
            imageService: mockImageService,
            logoutService: mockLogoutService
        )
        
        let spy = ProfileViewControllerSpy()
        viewController.loadViewIfNeeded()
        
        //when
        viewController.exitButton?.sendActions(for: .touchUpInside)
        
        //then
        XCTAssertTrue(spy.showLogoutAlertCalled)
    }
}
