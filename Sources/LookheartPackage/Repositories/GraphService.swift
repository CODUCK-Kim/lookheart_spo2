//
//  File.swift
//  
//
//  Created by 정연호 on 2024/04/12.
//

import Foundation

@available(iOS 13.0.0, *)
public class GraphService {
    
    /// eq(0) : jhaseung@medsyslab.co.kr
    /// date(1) : 2024-01-15 05:00:00
    /// timeZone(2) : +09:00/Asia/Seoul/KR
    /// year(3) : 2024
    /// month(4) : 1
    /// day(5) : 15
    /// hour(6) : 9
    /// data(7 ~ 11) : 1984|1495|307|98|9
    /// 추후에 파싱 부분과 데이터 모델링 하는 부분 분리해야함!!
    func getHourlyData(
        startDate: String,
        endDate: String
    ) async -> ([HourlyData]?, NetworkResponse) {
        let parameters: [String: Any] = [
            "eq": "jhaseung@medsyslab.co.kr",       // test
//            "eq": propEmail,
            "startDate": startDate,
            "endDate": endDate
        ]
        
        do {
            let hourlyData = try await AlamofireController.shared.alamofireControllerForString(
                parameters: parameters,
                endPoint: .getHourlyData,
                method: .get)
            
            guard !hourlyData.contains("result = 0") else {
                return (nil, .noData)
            }
            
            let newlineData = hourlyData.split(separator: "\n").dropFirst()
            guard newlineData.count > 0 else {
                return (nil, .invalidResponse)
            }
            
            let splitData = newlineData.first?.split(separator: "\r\n")
            var parsedRecords = [HourlyData]()
            
            if let datalist = splitData {
                for data in datalist {
                    let fields = data.split(separator: "|")
                    if fields.count == 12 {
                        guard let step = Int(fields[7]),
                              let distance = Int(fields[8]),
                              let cal = Int(fields[9]),
                              let activityCal = Int(fields[10]),
                              let arrCnt = Int(fields[11]) else {
                            continue // Skip this record if any conversions fail
                        }
                        
                        let utcDateTime = String(fields[1])
                        
                        if let localDateTime = DateTimeManager.shared.convertUtcToLocal(utcTimeStr: utcDateTime) {
                            let splitLocalDateTime = localDateTime.split(separator: " ")
                            let localDate = String(splitLocalDateTime[0])
                            let localTime = String(splitLocalDateTime[1])
                            
                            let splitDate = localDate.split(separator: "-")
                            let splitTime = localTime.split(separator: ":")
                                                        
                            parsedRecords.append(
                                HourlyData(
                                    eq: String(fields[0]),
                                    timezone: String(fields[2]),
                                    date: localDate,
                                    year: String(splitDate[0]),
                                    month: String(splitDate[1]),
                                    day: String(splitDate[2]),
                                    hour: String(splitTime[0]),
                                    step: String(step),
                                    distance: String(distance),
                                    cal: String(cal),
                                    activityCal: String(activityCal),
                                    arrCnt: String(arrCnt)
                                )
                            )
                        }
                    }
                }
                
                return (parsedRecords, .success)
            } else {
                return (nil, .failer)
            }
        } catch {
            return (nil, AlamofireController.shared.handleError(error))
        }
    }
}
