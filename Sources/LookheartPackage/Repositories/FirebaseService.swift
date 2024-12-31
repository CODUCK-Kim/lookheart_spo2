//
//  File.swift
//  
//
//  Created by KHJ on 2024/04/15.
//

import Foundation


@available(iOS 13.0.0, *)
class FirebaseService {
    func sendFirebaseToken(
        id: String,
        password: String,
        phone: String, 
        token: String
    ) async -> NetworkResponse {
        let params: [String: Any] = [
            "empid": id,
            "pw": password,
            "phone": phone,
            "token": token
        ]
        
        do {
            let response = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .getCheckLogin,
                method: .get)
            
            if response.contains("true") {
                return .success
            } else if response.contains("false") {
                return .failer
            } else {
                return .invalidResponse
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }
}
