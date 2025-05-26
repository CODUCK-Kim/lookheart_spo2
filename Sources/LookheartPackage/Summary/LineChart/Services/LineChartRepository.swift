//
//  File.swift
//  
//
//  Created by KHJ on 10/29/24.
//

import Foundation
import DGCharts


class LineChartRepository {
    // DI
    private let service: LineChartService
    private let dateTimeManager: DateTimeManager
    
    //
    private var targetLocalDate: String
    private var lineChartType: LineChartType
    private var lineChartDateType: LineChartDateType
    private let decoder = JSONDecoder()
    
    init (
        service: LineChartService,
        dateTimeManager: DateTimeManager
    ) {
        self.service = service
        self.dateTimeManager = dateTimeManager
        
        targetLocalDate = dateTimeManager.getCurrentLocalDate()
        lineChartType = .BPM
        lineChartDateType = .TODAY
    }
    
    
    
    
    
    
    // MARK: -
    func getLineChartGropData() async -> (
        data: LineChartModel?,
        networkResponse: NetworkResponse
    ) {
        let startDate = getStartDate()
        let endDate = getEndDate()
        
        let data = await service.fetchData(
            startDate: startDate,
            endDate: endDate,
            type: lineChartType
        )
        
        switch data.response {
        case .success:
            // string -> parsing
            let parsingData = getParsingData(data.result)
            
            // parsing -> group
            guard let parsingResult = parsingData.result else {
                return (nil, parsingData.response)
            }
                        
            let groupData = groupDataByDate(parsingResult)
            
            // data dict, time table -> add model
            let lineChartGroupedData = getLineChartGroupedData(groupData)
            
            // result model
            let lineChartModel = getChartModel(lineChartGroupedData)
            
            return (lineChartModel, data.response)
        default:
            return (nil, data.response)
        }
    }
    
    
    
    
    
    // MARK: -
    private func getParsingData(_ data: String?) -> (
        result: [LineChartDataModel]?,
        response: NetworkResponse
    ) {
        switch (lineChartType) {
        case .BPM, .HRV, .SPO2, .BREATHE:
            return parsingBpmHrvData(data)
        case .STRESS:
            return parsingStressData(data)
        }
    }
    
    
    // bpm & hrv
    private func parsingBpmHrvData(_ data: String?) -> (result: [LineChartDataModel]?, response: NetworkResponse) {
        guard let resultData = data else {
            return (nil, .noData)
        }
        
        guard !resultData.contains("result = 0") else {
            return (nil, .noData)
        }
        
        let newlineData = resultData.split(separator: "\n").dropFirst()
        
        guard newlineData.count > 0 else {
            return (nil, .invalidResponse)
        }
        
        guard let splitData = newlineData.first?.split(separator: "\r\n") else {
            return (nil, .invalidResponse)
        }
        
        let changedFormatData = LineChartDataModel.changeFormat(datalist: splitData, dateList: getDateList())
        
        changedFormatData.forEach {
            print($0)
        }
        
        return (changedFormatData, .success)
    }
    
    
    // stress
    private func parsingStressData(_ data: String?) -> (result: [LineChartDataModel]?, response: NetworkResponse) {
        guard let resultData = data else {
            return (nil, .noData)
        }
        
        if resultData.count < 3 {
            return (nil, .noData)
        }

        guard let jsonData = resultData.data(using: .utf8) else {
            print("Error: Parsing Stress Data")
            return (nil, .invalidResponse)
        }
        
        do {
            let stressDataArray = try decoder.decode([StressDataModel].self, from: jsonData)
            
            let changedFormatData = LineChartDataModel.changeFormat(stressData: stressDataArray, dateList: getDateList())
            
            return (changedFormatData, .success)
        } catch {
            print("Error decoding JSON: \(error)")
            
            return (nil, .invalidResponse)
        }
    }
    
    
    // group data
    private func groupDataByDate(
        _ parsingData : [LineChartDataModel]
    ) -> [String: [LineChartDataModel]] {
        let groupedData = parsingData.reduce(into: [String: [LineChartDataModel]]()) { dict, data in
            
            switch lineChartType {
            case .BPM, .HRV, .SPO2, .BREATHE:
                // 날짜별("YYYY-MM-DD") 데이터 그룹화
                let dateKey = String(data.writeDate)
                dict[dateKey, default: []].append(data)
            case .STRESS:
                // 항목별(pns, sns) 데이터 그룹화
                dict["sns", default: []].append(data)
                dict["pns", default: []].append(data)
            }
        }
        
        return groupedData
    }
    
    
    // dictionary Data, time table
    func getLineChartGroupedData(_ groupData: [String : [LineChartDataModel]]) -> LineChartModel {
        var dictData: [String : [String : LineChartDataModel]] = [:]
        var entries: [String : [ChartDataEntry]] = [:]
        
        for (date, dataForDate) in groupData {
            var timeDictionary: [String: LineChartDataModel] = [:]
            
            for data in dataForDate {
                timeDictionary[data.writeTime] = data
            }
            
            // dictionary
            dictData[date] = timeDictionary
            
            // init entry
            entries[date] = [ChartDataEntry]()
        }
        
    
        // time Table
        let timeTable: [String] = {
            switch lineChartType {
            case .BPM, .HRV, .STRESS:
                return Set(groupData.values.flatMap { $0.map { $0.writeTime } }).sorted()
            case .SPO2:
                return groupData.flatMap { $0.value }   // 값이 없는 time table 제외
                    .filter { ($0.spo2 ?? 0.0) > 0 }
                    .map { $0.writeTime }
            case .BREATHE:
                return groupData.flatMap { $0.value }
                    .filter { ($0.breathe ?? 0.0) > 0 }
                    .map { $0.writeTime }
            }
        }()
        
        return LineChartModel(
            entries: entries,
            dictData: dictData,
            timeTable: timeTable,
            chartType: lineChartType,
            dateType: lineChartDateType
        )
    }
        
    
    private func getChartModel(_ lineChartModel: LineChartModel) -> LineChartModel {
        var copyModel = lineChartModel
        
        var entries = lineChartModel.entries
        var valueTable: [Double] = []
        
        var stats: ChartStatistics? = nil
        var stressStats: StressChartStatistics? = nil
        
        for i in 0..<lineChartModel.timeTable.count {
            let time = lineChartModel.timeTable[i]
            
            // dictData: [date: [time: LineChartDataModel]]
            for (date, timeDict) in lineChartModel.dictData {
                guard let data = timeDict[time] else { continue }
                guard let yValue = getYValue(date, data) else { continue }
                
                
                // chart entries
                let entry = ChartDataEntry(x: Double(i), y: yValue)
                entries?[date]?.append(entry)
                
                // update stats
                switch lineChartModel.chartType {
                case .BPM, .HRV:
                    if stats == nil { stats = ChartStatistics() }
                    
                    stats?.update(with: yValue)
                    
                    valueTable.append(yValue)   // standard deviation value table
                    
                case .STRESS:
                    if stressStats == nil { stressStats = StressChartStatistics() }
                    
                    if date == "pns" {
                        stressStats?.pns.update(with: yValue)
                    } else {
                        stressStats?.sns.update(with: yValue)
                    }
                case .SPO2, .BREATHE:
                    if stats == nil { stats = ChartStatistics() }
                    stats?.update(with: yValue)
                }
            }
        }
        
        // chart data
        copyModel.entries = entries
        copyModel.timeTable = lineChartModel.timeTable
        
        // stats
        copyModel.stats = stats
        copyModel.stressStats = stressStats
        copyModel.standardDeviationValue = getStandardDeviationValue(copyModel, valueTable)
        
        return copyModel
    }
    
    
    private func getYValue(
        _ date: String,
        _ lineChartDataModel: LineChartDataModel
    ) -> Double? {
        return switch lineChartType {
        case .BPM:
            lineChartDataModel.bpm
        case .HRV:
            lineChartDataModel.hrv
        case .STRESS:
            date == "pns" ? lineChartDataModel.pns : lineChartDataModel.sns
        case .SPO2:
            lineChartDataModel.spo2 != 0 ? lineChartDataModel.spo2 : nil
        case .BREATHE:
            lineChartDataModel.breathe != 0 ? lineChartDataModel.breathe : nil
        }
    }
    
    
    private func getStandardDeviationValue(
        _ lineChartModel: LineChartModel,
        _ valueTable: [Double]
    ) -> Double? {
        switch lineChartModel.chartType {
        case .BPM, .HRV:
            guard let average = lineChartModel.stats?.average else { return nil }
            
            var sumSquareValue = 0.0
            
            valueTable.forEach { value in
                let deviation = value - average
                let squaredDeviation = deviation * deviation // 편차 제곱
                
                sumSquareValue += squaredDeviation
            }
            
            let variance = sumSquareValue / Double(valueTable.count) // 분산
            
            return sqrt(variance) // 제곱근
            
        case .SPO2, .BREATHE, .STRESS:
            return nil
        }
    }
    
    
    
    
    // MARK: -
    func updateTargetDate(_ nextDate: Bool) {
        if let updateDate = dateTimeManager.adjustDate(
            targetLocalDate,
            offset: nextDate ? 1 : -1,
            component: .day
        ) {
            targetLocalDate = updateDate
        }
    }
    
    func updateTargetDate(_ date: Date) {
        targetLocalDate = dateTimeManager.getFormattedDateString(date)
    }
    
    func getDisplayDate() -> String {
        switch (lineChartDateType) {
        case .TODAY:
            return targetLocalDate
        case .TWO_DAYS, .THREE_DAYS:
            let offest = if lineChartDateType == .TWO_DAYS { 1 } else { 2 }
            if let startDate = dateTimeManager.adjustDate(
                targetLocalDate,
                offset: -offest,
                component: .day)
            {
                return "\(startDate.suffix(5)) ~ \(targetLocalDate.suffix(5))"
            } else {
                return targetLocalDate
            }
        }
    }
    
    private func getStartDate() -> String {
        let day = switch lineChartDateType {
        case .TODAY:        0
        case .TWO_DAYS:     1
        case .THREE_DAYS:   2
        }
        
        if let startUTCDate = dateTimeManager.localDateStartToUtcDateString(targetLocalDate) {
            return dateTimeManager.adjustDate(startUTCDate, offset: -day, component: .day) ?? targetLocalDate
        } else {
            return dateTimeManager.adjustDate(targetLocalDate, offset: -day, component: .day) ?? targetLocalDate
        }
    }
    
    private func getEndDate() -> String {
        if let endUTCDate = dateTimeManager.localDateEndToUtcDateString(targetLocalDate) {
            return dateTimeManager.adjustDate(endUTCDate, offset: 1, component: .day) ?? targetLocalDate
        } else {
            return dateTimeManager.adjustDate(targetLocalDate, offset: 1, component: .day) ?? targetLocalDate
        }
    }
    
    private func getDateList() -> [String] {
        let count = switch lineChartDateType {
        case .TODAY:        1
        case .TWO_DAYS:     2
        case .THREE_DAYS:   3
        }
        
        // -(count-1) ... 0 까지 1씩 증가하는 스트라이드
        let offsets = stride(from: -(count - 1), through: 0, by: 1)
        return offsets.map { offset in
            dateTimeManager
                .adjustDate(targetLocalDate, offset: offset, component: .day)
                ?? targetLocalDate
        }
    }
    
    // MARK: -
    func refreshData(_ type: LineChartType) {
        lineChartType = type
        lineChartDateType = .TODAY
        targetLocalDate = dateTimeManager.getCurrentLocalDate()
    }
    
    func updateChartType(type: LineChartType) {
        lineChartType = type
    }
    
    func updateChartDateType(type: LineChartDateType) {
        lineChartDateType = type
    }
}
