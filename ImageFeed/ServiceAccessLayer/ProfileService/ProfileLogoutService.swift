import Foundation
import WebKit

final class ProfileLogoutService: ProfileLogoutServiceProtocol {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        cleanAuthData()
        resetServices()
        navigateToNavigationScreen()
        
    }
    
    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanAuthData() {
        OAuth2TokenStorage.shared.token = nil
    }
    
    private func resetServices() {
        ProfileService.shared.reset()
        
        ProfileImageService.shared.clearCache()
        
        ImagesListService.shared.reset()
        ImagesListService.shared.clearCache()
        ImagesListService.shared.reset()
    }
    
    private func navigateToNavigationScreen() {
        DispatchQueue.main.async {
            guard #available(iOS 13.0, *),
                  let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: \.isKeyWindow),
                  let navigationController = window.rootViewController as? UINavigationController
            else { return }
            
            navigationController.popToRootViewController(animated: true)
        }
    }
}

