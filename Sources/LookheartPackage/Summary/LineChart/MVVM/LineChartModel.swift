import Foundation
import DGCharts

struct LineChartModel {
    var entries: [String : [ChartDataEntry]]?
    var dictData: [String: [String: LineChartDataModel]]
    var timeTable: [String]
    var chartType: LineChartType
    var dateType: LineChartDateType
    
    var stats: ChartStatistics? = nil
    var stressStats: StressChartStatistics? = nil
    var standardDeviationValue: Double? = nil
}

struct StressDataModel: Codable {
    let writeTime: String
    let pnsPercent: Double
    let snsPercent: Double
    
    enum CodingKeys: String, CodingKey {
        case writeTime = "writetime"
        case pnsPercent = "pns_percent"
        case snsPercent = "sns_percent"
    }
}

struct LineChartDataModel {
    var idx: String?
    var eq: String?
    var writeDateTime: String
    var writeDate: String
    var writeTime: String
    var timezone: String?
    
    // bpm, hrv
    var bpm: Double?
    var temp: Double?
    var hrv: Double?
    
    // stress
    var pns: Double?
    var sns: Double?
    var stress: Double?
    
    // spo2, breathe
    var spo2: Double?
    var breathe: Double?
        
    // bpm, hrv
    static func changeFormat(
        datalist: [Substring],
        dateList: [String]
    ) -> [LineChartDataModel] {
        var parsedRecords = [LineChartDataModel]()
        
        for data in datalist {
            let fields = data.split(separator: "|")
            
            if fields.count == 9 {
                guard let bpm = Int(fields[4]),
                      let temp = Double(fields[5]),
                      let hrv = Int(fields[6]),
                      let spo2 = Double(fields[7]),
                      let breathe = Int(fields[8]) else {
                    continue
                }
                
                let utcDateTime = String(fields[2])
                
                if let localDateTime = DateTimeManager.shared.convertUtcToLocal(utcTimeStr: utcDateTime) {
                    let splitLocalDateTime = localDateTime.split(separator: " ")
                    let localDate = String(splitLocalDateTime[0])
                    let localTime = String(splitLocalDateTime[1])
                    
                    if dateList.contains(localDate) {
                        parsedRecords.append(
                            LineChartDataModel(
                                idx: String(fields[0]),
                                eq: String(fields[1]),
                                writeDateTime: localDateTime,
                                writeDate: localDate,
                                writeTime: localTime,
                                timezone: String(fields[3]),
                                bpm: Double(bpm),
                                temp: Double(temp),
                                hrv: Double(hrv),
                                spo2: Double(spo2),
                                breathe: Double(breathe)
                            )
                        )
                    }
                }
            }
        }
        
        return parsedRecords
    }
    
    // Stress
    static func changeFormat(
        stressData: [StressDataModel],
        dateList: [String]
    ) -> [LineChartDataModel] {
        var parsedRecords = [LineChartDataModel]()
        
        for data in stressData {
            if data.pnsPercent == 100.0 || data.snsPercent == 100.0 {
                continue
            }
            
            if let localDateTime = DateTimeManager.shared.convertUtcToLocal(utcTimeStr: data.writeTime) {
                let splitLocalDateTime = localDateTime.split(separator: " ")
                let localDate = String(splitLocalDateTime[0])
                let localTime = String(splitLocalDateTime[1])
                
                if dateList.contains(localDate) {
                    parsedRecords.append(
                        LineChartDataModel(
                            writeDateTime: data.writeTime,
                            writeDate: localDate,
                            writeTime: localTime,
                            pns: data.pnsPercent,
                            sns: data.snsPercent
                        )
                    )
                }
            }
        }
        return parsedRecords
    }
}
