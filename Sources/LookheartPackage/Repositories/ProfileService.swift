//
//  File.swift
//  
//
//  Created by 정연호 on 2024/04/12.
//

import Foundation

@available(iOS 13.0.0, *)
public class ProfileService {
    public init() {}
    
    public struct UserHealthData {
        public var hour: Int? = nil
        public var calorie: Int = 0
        public var activityCalorie: Int = 0
        public var step: Int = 0
        public var distance: Int = 0
        public var arrCnt: Int = 0
    }
    
    private struct ArrCnt: Codable {
        let arrCnt: String
    }
    
    private struct Email: Codable {
        let eq: String
    }
    
    public func getProfile(id: String) async -> (UserProfile?, NetworkResponse) {
        let params: [String: Any] = [
            "empid": id
        ]
        
        do {
            let profiles: [UserProfile] = try await AlamofireController.shared.alamofireControllerAsync(
                parameters: params,
                endPoint: .getProfile,
                method: .get
            )
            
            var phoneNumbers: [String] = []
            
            for profile in profiles { // guardian Phone Numbers
                if let phones = profile.phone {
                    phoneNumbers.append(phones)
                }
            }
            
            if let userProfile = profiles.first {
                UserProfileManager.shared.guardianPhoneNumber = phoneNumbers
                return (userProfile, .success)
            } else {
                return (nil, .noData)
            }
            
        } catch {
            return (nil, AlamofireController.shared.handleError(error))
        }
    }
    
    
    
    public func postAccountDeletion(params: [String: Any]) async -> NetworkResponse {
        do {
            let response = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postSetProfile,
                method: .post)
            
            if response.contains("true") {
                return .success
            } else {
                return .failer
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }
    
    
    public func postUpdateLogout() async {
        let params: [String: Any] = [
            "kind": "updateDifferTime",
            "eq": propEmail,
            "differtime": "0"
        ]
        
        do {
            let response = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postSetProfile,
                method: .post)
            
            print("postUpdateLogout: \(response)")
        } catch {
            print("postUpdateLogout: \(error)")
        }
    }
    
    
    public func postSignup(params: [String: Any]) async -> NetworkResponse {
        do {
            let response = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postSetProfile,
                method: .post)
                    
            print("postSignup \(response)")
            
            if response.contains("true") {
                return .success
            } else if response.contains("false") {
                return .failer
            } else {
                return .invalidResponse
            }
        } catch {
            print("postSignup: \(error)")
            return AlamofireController.shared.handleError(error)
        }
    }
    
    public func postGuardian(phone:[String]) async -> NetworkResponse {
        let params: [String: Any] = [
            "eq": propEmail,
            "timezone": propTimeZone,
            "writetime": propCurrentDateTime,
            "phones": phone
        ]
        
        do {
            let response = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postSetGuardian,
                method: .post)
            
            print("postGuardian \(response)")
            
            if response.contains("true") {
                return .success
            } else if response.contains("false") {
                return .failer
            } else {
                return .invalidResponse
            }
        } catch {
            print("postGuardian: \(error)")
            return AlamofireController.shared.handleError(error)
        }
    }
    
    public func getCheckID(id: String) async -> NetworkResponse {
        let params: [String: Any] = [
            "empid": id
        ]
        
        do {
            let response = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .getCheckDupID,
                method: .get)
            
            print("getCheckID \(response)")
            
            if response.contains("true") {
                return .success
            } else if response.contains("false") {
                return .failer
            } else {
                return .invalidResponse
            }
            
        } catch {
            print("getCheckID: \(error)")
            return AlamofireController.shared.handleError(error)
        }
    }
    
    
    public func postUpdatePassword(
        id: String,
        password: String
    ) async -> NetworkResponse {
        let params: [String: Any] = [
            "kind": "updatePWD",
            "eq": id,
            "password": password
        ]
        
        do {
            let response = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postSetProfile,
                method: .post)
            
            print("postUpdatePassword \(response)")
            
            if response.contains("true") {
                return .success
            } else if response.contains("false") {
                return .failer
            } else {
                return .invalidResponse
            }
            
        } catch {
            print("postUpdatePassword: \(error)")
            return AlamofireController.shared.handleError(error)
        }
    }
    
    public func getFindID(
        name: String, 
        phoneNumber: String,
        birthday: String
    ) async -> (String?, NetworkResponse) {
        // Test
//        let params: [String: Any] = [
//            "성명": name,
//            "핸드폰": phoneNumber,
//            "생년월일": birthday
//        ]
        
        // Real
        let params: [String: Any] = [
            "eqname": name,
            "phone": phoneNumber,
            "birth": birthday
        ]
        
        do {
            let response: [Email] = try await AlamofireController.shared.alamofireControllerAsync(
                parameters: params,
                endPoint: .getFindID,
                method: .get)
            
            print("getFindID \(response)")
            
            if let id = response.first {
                return (id.eq, .success)
            } else {
                return (nil, .failer)
            }
        } catch {
            print("getFindID Error: \(error)")
            return (nil, AlamofireController.shared.handleError(error))
        }
    }
    
    
    public func getUserHealthData(
        startDate: String,
        endDate: String
    ) async -> (
        userHealthData: UserHealthData,
        lastUserHealthData: UserHealthData
    )? {
        let parameters: [String: Any] = [
            "eq": propEmail,
            "startDate": startDate,
            "endDate": endDate
        ]
        
        do {
            let arrCnt = await getArrCnt(startDate: startDate, endDate: endDate)
            
            let hourlyData = try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .getHourlyData,
                method: .get)
            
            guard !hourlyData.contains("result = 0") else {
                print("getUserHealthData noData")
                return nil
            }
            
            let newlineData = hourlyData.split(separator: "\n").dropFirst()
            guard newlineData.count > 0 else {
                print("getUserHealthData invalidResponse")
                return nil
            }
            
            if let parsingData = getParsingHourlyData(hourlyData) {
                // update health data
                var userHealthData = parsingData.userHealthData
                var lastUserHealthData = parsingData.lastUserHealthData
                
                // update arr Cnt data
                userHealthData.arrCnt = arrCnt.totalCnt
                lastUserHealthData.arrCnt = arrCnt.lastCnt
            
                return (
                    userHealthData: userHealthData,
                    lastUserHealthData: lastUserHealthData
                )
            } else {
                print("getUserHealthData parsingData Err")
                return nil
            }
        } catch {
            print(AlamofireController.shared.handleError(error))
            return nil
        }
    }
    
    private func getArrCnt(
        startDate: String,
        endDate: String
    ) async -> (
        totalCnt: Int,
        lastCnt: Int
    ) {
        let parameters: [String: Any] = [
            "eq": propEmail,
            "startDate": startDate,
            "endDate": endDate
        ]
        
        do {
            let response: [ArrDateEntry] = try await AlamofireController.shared.alamofireControllerAsync(
                parameters: parameters,
                endPoint: .getArrListData,
                method: .get)
            
            let todayArrCnt = response.filter {
                DateTimeManager.shared.checkLocalDate(utcDateTime: $0.writetime) && $0.address == nil
            }.count
            
            let lastArrCnt = response.filter { item in
                guard
                    let timePart = item.writetime.split(separator: " ").last,
                    let hourPart = timePart.split(separator: ":").first
                else {
                    return false
                }
                
                return item.address == nil && String(hourPart) == DateTimeManager.shared.getCurrentUtcHour()
            }.count
            
            return (totalCnt: todayArrCnt, lastCnt: lastArrCnt)
        } catch {
            print(AlamofireController.shared.handleError(error))
            return (totalCnt: 0, lastCnt: 0)
        }
    }
    
    private func getParsingHourlyData(_ data: String?
    ) -> (
        userHealthData: UserHealthData,
        lastUserHealthData: UserHealthData
    )? {
        if let hourlyData = data {
            var userHealthData = UserHealthData()
            var lastUserHealthData = UserHealthData()
            
            let newlineData = hourlyData.split(separator: "\n").dropFirst()
            guard newlineData.count > 0 else {
                return nil
            }
            
            let splitData = newlineData.first?.split(separator: "\r\n")
            
            if let splitData = splitData {
                for data in splitData {
                    let fields = data.split(separator: "|")
                    if fields.count == 12 {
                        guard let prevHour = Int(fields[6]),
                              let step = Int(fields[7]),
                              let distance = Int(fields[8]),
                              let calorie = Int(fields[9]),
                              let activityCalorie = Int(fields[10]),
                              let arrCnt = Int(fields[11]) else {
                            continue // Skip this record if any conversions fail
                        }
                        userHealthData.calorie += calorie
                        userHealthData.activityCalorie += activityCalorie
                        userHealthData.step += step
                        userHealthData.distance += distance
                        userHealthData.arrCnt += arrCnt
                        
                        lastUserHealthData = UserHealthData(
                            hour: prevHour,
                            calorie: calorie,
                            activityCalorie: activityCalorie,
                            step: step,
                            distance: distance,
                            arrCnt:  arrCnt
                        )
                    }
                }
                return (userHealthData: userHealthData, lastUserHealthData: lastUserHealthData)
            }
        }
        
        return nil
    }
}
