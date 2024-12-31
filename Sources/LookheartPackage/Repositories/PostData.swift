//
//  File.swift
//  
//
//  Created by 정연호 on 2024/04/12.
//

import Foundation

@available(iOS 13.0.0, *)
public class PostData {
    public static let shared = PostData()
    
    public init() {}
    
    
    public func sendEcgData(
        ecgData: [Int],
        bpm: Int, 
        writeDateTime: String
    ) async {
        let params: [String: Any] = [
            "kind": "ecgByteInsert",
            "eq": propEmail,
            "writetime": writeDateTime,
            "timezone": propTimeZone,
            "bpm": bpm,
            "ecgPacket": ecgData
        ]
        
        
        do {
            _ = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postEcgData,
                method: .post)
//            print("EcgData: \(ecgData)")
        } catch {
            print("EcgData Send Error: \(error)")
        }
    }
    
    
    
    
    public func sendTenSecondData(
        tenSecondData: [String: Any],
        writeDateTime: String
    ) async {
        var params: [String: Any] = [
            "kind": "BpmDataInsert",
            "eq": propEmail,
            "timezone": propTimeZone,
            "writetime": writeDateTime
        ]
        
        params.merge(tenSecondData) { (current, _) in current }
        
        do {
            let response = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postTenSecondData,
                method: .post)
            
//            print("TenSecondeData: \(tenSecondData)")
            print("TenSecondeData response: \(response)")
            
        } catch {
            print("TenSecondeData Send Error: \(error)")
        }
    }
    
    
    
    public func sendHourlyData(hourlyData: [String: Any]) async {
        var params: [String: Any] = [
            "kind": "calandInsert",
            "eq": propEmail,
        ]
        
        params.merge(hourlyData) { (current, _) in current }
        
        do {
            _ = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postHourlyData,
                method: .post)
            
//            print("sendHourlyData: \(hourlyData)")
        } catch {
            print("sendHourlyData Send Error: \(error)")
        }
    }
    
    
    public func sendArrData(
    arrData: [String: Any]
    ) async -> NetworkResponse {
        var params: [String: Any] = [
            "kind": "arrEcgInsert",
            "eq": propEmail,
        ]
        
        params.merge(arrData) { (current, _) in current }
        
        do {
            let arrData = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postArrData,
                method: .post)
            
            print("send arrData: \(arrData)")
            
            if arrData.contains("true") {
                return .success
            } else {
                return .failer
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }
    
    
    public func postEmergency(
        _ address: String,
        _ currentDateTime: String,
        _ ecgData: [Double]
    ) async -> NetworkResponse {
        let arrArray = ecgData.map { String($0) }
        let emergencyEcgData = arrArray.joined(separator: ",")
        
        let params: [String: Any] = [
            "kind": "arrEcgInsert",
            "eq": propEmail,
            "timezone": propTimeZone,
            "writetime": currentDateTime,
            "ecgPacket": emergencyEcgData,
            "arrStatus": "",
            "bodystate": "1",
            "address": address
        ]
        
        do {
            let response = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postArrData,
                method: .post)
            
            if response.contains("true") {
                return .success
            } else {
                return .failer
            }
        } catch {
            print("post Emergency Error: \(error)")
            return AlamofireController.shared.handleError(error)
        }
    }
}
