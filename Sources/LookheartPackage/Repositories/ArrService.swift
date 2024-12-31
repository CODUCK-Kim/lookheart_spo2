//
//  File.swift
//  
//
//  Created by 정연호 on 2024/04/12.
//

import Foundation

@available(iOS 13.0.0, *)
public class ArrService {
    public init() {}
    
    public func getArrList(
        startDate: String,
        endDate: String
    ) async -> ([ArrDateEntry]?, NetworkResponse) {
        let parameters: [String: Any] = [
            "eq": propEmail,
            "startDate": startDate,
            "endDate": endDate
        ]
        
        do {
            let arrList: [ArrDateEntry] = try await AlamofireController.shared.alamofireControllerAsync(
                parameters: parameters,
                endPoint: .getArrListData,
                method: .get)
            
            return (arrList, .success)
        } catch {
            return (nil, AlamofireController.shared.handleError(error))
        }
    }
    
    public func getArrData(
        startDate: String,
        emergency: Bool
    ) async -> (ArrData?, NetworkResponse) {
        let parameters: [String: Any] = [
            "eq": propEmail,
            "startDate": startDate,
            "endDate": ""
        ]
        
        do {
            let arrData: [ArrEcgData] = try await AlamofireController.shared.alamofireControllerAsync(
                parameters: parameters,
                endPoint: .getArrListData,
                method: .get
            )
            
            // Arr[0..3..ECG_MAX_ARRAY] : ["13:45:38", "+09:00/Asia/Seoul/KR", "rest", "arr", ...ECG]
            // Emergency[0..ECG_MAX_ARRAY] : [ECG]
            let startEcgDataIdx = emergency ? 0 : 4
            
            if let splitArrData = arrData.first?.ecgpacket.split(separator: ",") {
                let ecgData = splitArrData[startEcgDataIdx...].compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
                
                let writeTime = emergency ? "" : self.removeWsAndNl(splitArrData[0])
                let bodyStatus = emergency ? "" : self.removeWsAndNl(splitArrData[2])
                let arrType = emergency ? "" : self.removeWsAndNl(splitArrData[3])
                
                let arrData = ArrData.init(
                    idx: "0",
                    writeTime: "0",
                    time: writeTime,
                    timezone: "0",
                    bodyStatus: bodyStatus,
                    type: arrType,
                    data: ecgData
                )

                return (arrData, .success)
            }
            
            return (nil, .failer)
        } catch {
            return (nil, AlamofireController.shared.handleError(error))
        }
    }
    
    private func removeWsAndNl(_ string: Substring) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    public func getEmergencyData(startDate: String) async {
        let parameters: [String: Any] = [
            "eq": propEmail,
            "startDate": startDate,
            "endDate": ""
        ]
        print("startDate: \(startDate)")
        do {
            let emergencyData = try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .getArrListData,
                method: .get)
            
            print("emergencyData: \(emergencyData)")

        } catch {
            
        }
    }
}
