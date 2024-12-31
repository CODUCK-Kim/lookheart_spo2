//
//  File.swift
//  
//
//  Created by 정연호 on 2024/04/12.
//

import Foundation

@available(iOS 13.0.0, *)
public class AuthService {
    
    func getDupPhoneNumber(
        phone phoneNumber: String
    ) async -> NetworkResponse {
        let parameters: [String: Any] = [
            "phone": phoneNumber
        ]
        
        do {
            let checkPhoneNumber = try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .getCheckPhoneNumber,
                method: .get)
            
            if checkPhoneNumber.contains("result") && checkPhoneNumber.contains("true") {
                return .success
            } else {
                return .failer
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }
    
    func getSendSms(
        phone phoneNumber: String,
        code nationalCode: String
    ) async -> NetworkResponse {
        let parameters: [String: Any] = [
            "phone": phoneNumber,
            "nationalCode": nationalCode
        ]
        
        do {
            let sendSms = try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .getSendSms,
                method: .get)
            
            if sendSms.contains("true") {
                return .success
            } else if sendSms.contains("false"){
                return .failer
            } else {
                return .noData
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }
    
    func getCheckSmsCode(
        phone phoneNumber: String,
        code authNumber: String
    ) async -> NetworkResponse {
        let parameters: [String: Any] = [
            "phone": phoneNumber,
            "code": authNumber
        ]
        
        do {
            let checkSms = try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .getCheckSMS,
                method: .get)
            if checkSms.contains("true") {
                return .success
            } else {
                return .failer
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }
}
