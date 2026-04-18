import Foundation

final class OAuth2TokenStorage {
  
    private let tokenKey = "OAuth2AccessToken"
    private let userDefaults = UserDefaults.standard
        
        var token: String? {
            get {
                UserDefaults.standard.string(forKey: tokenKey)
            }
            set {
                UserDefaults.standard.set(newValue, forKey: tokenKey)
            }
        }
    }
