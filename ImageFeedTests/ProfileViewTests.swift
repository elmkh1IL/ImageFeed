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
    
    // 1 - проверка обновления данных профиля
    
    func testUpdateProfileDetails() {
        
        // given
        let mockProfileService = MockProfileService()
        let profile = Profile(username: "новый юзернейм", name: "Новое имя", loginName: "@юзернейм", bio: "новое био")
        
        mockProfileService.profile = profile
        
        let viewController = ProfileViewController(
            profileService: mockProfileService,
            imageService: MockProfileImageService(),
            logoutService: MockProfileLogoutService(),
        )
        
        //when
        viewController.loadViewIfNeeded()
        
        //then
        XCTAssertEqual(viewController.nameLabel?.text, "Новое имя")
        XCTAssertEqual(viewController.usernameLabel?.text, "@юзернейм")
        XCTAssertEqual(viewController.descriptionLabel?.text, "новое био")
    }
    
    // 2 - проверка создания кнопки
    
    func testExitButton() {
        let vc = ProfileViewController(
            profileService: MockProfileService(),
            imageService: MockProfileImageService(),
            logoutService: MockProfileLogoutService()
        )
        
        vc.loadViewIfNeeded()
        XCTAssertNotNil(vc.exitButton)
    }
    
    // 3 - есть кнопка подтверждения выхода
    
    func testLogoutAlertYesButton() {
        let vc = ProfileViewController(
            profileService: MockProfileService(),
            imageService: MockProfileImageService(),
            logoutService: MockProfileLogoutService()
        )
        
        let alert = vc.makeLogoutAlert()
        let yesButton = alert.actions.first {
            $0.title == "Да"
        }
        
        XCTAssertNotNil(yesButton)
    }
    
    // 4 - есть кнопка нет
    
    func testLogoutAlertNoButton() {
        let vc = ProfileViewController(
            profileService: MockProfileService(),
            imageService: MockProfileImageService(),
            logoutService: MockProfileLogoutService()
        )
        
        let alert = vc.makeLogoutAlert()
        let noButton = alert.actions.first {
            $0.title == "Нет"
        }
        
        XCTAssertNotNil(noButton)
    }
}
