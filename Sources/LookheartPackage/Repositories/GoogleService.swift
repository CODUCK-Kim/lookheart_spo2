//
//  File.swift
//  
//
//  Created by KHJ on 8/1/24.
//

import Foundation
import AuthenticationServices

public class GoogleService {
    public struct GoogleUser: Codable {
        public let email: String
        public let firstName: String
        public let lastName: String
        let socialProvider: String
        public let externalId: String
        let accessToken: String
    }
    
    public init() {}
    
    public func getGoogleLoginSession(callback: @escaping (GoogleUser?, Error?) -> Void) -> ASWebAuthenticationSession? {
        let authURLString = AlamofireController.shared.getBaseURL() + "google/callback"
        
        guard let authURL = URL(string: authURLString) else {
            print("Invalid Google Login URL")
            return nil
        }
        
        return ASWebAuthenticationSession(url: authURL, callbackURLScheme: nil) { callbackURL, error in
            
            // Error
            if let error = error {
                print("Error during login: \(error.localizedDescription)")
                callback(nil, error)
                return
            }
            
            
            // CallBack
            guard let callbackURL = callbackURL else {
                callback(nil, NSError(domain: "GoogleAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Callback URL is nil"]))
                return
            }
            
            let queryItems = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems
            
            let googleUserData = self.getGoogleLoginData(queryItems?.first?.value)
            
            callback(googleUserData, nil)
        }
    }
    
    private func getGoogleLoginData(_ stringData: String?) -> GoogleUser? {
        if let data = stringData?.data(using:  .utf8) {
            do {
                let user = try JSONDecoder().decode(GoogleUser.self, from: data)
                return user
            } catch {
                print("GoogleLoginData JSON 디코딩 오류: \(error.localizedDescription)")
            }
        }
        return nil
    }
}
