//
//  File.swift
//  
//
//  Created by KHJ on 10/29/24.
//

import Foundation
import DGCharts
import UIKit


class LineChartController {
    private let dateTime: MyDateTime
    
    init (dateTime: MyDateTime) {
        self.dateTime = dateTime
    }
    
    
    func setLineChart(
        lineChart: LineChartView,
        noDataText: String = "",
        fontSize: CGFloat = 15,
        weight: UIFont.Weight = .bold,
        granularity: Double = 1,
        labelPosition: XAxis.LabelPosition = .bottom,
        xAxisEnabled: Bool = true,
        drawGridLinesEnabled: Bool = false,
        rightAxisEnabled: Bool = false,
        dragEnabled: Bool = true,
        drawMarkers: Bool = false,
        pinchZoomEnabled: Bool = false,
        doubleTapToZoomEnabled: Bool = false,
        highlightPerTapEnabled: Bool = false
    ) {
        lineChart.do {
            $0.noDataText = noDataText
            $0.xAxis.enabled = xAxisEnabled
            $0.legend.font = .systemFont(ofSize: fontSize, weight: weight)
            $0.xAxis.granularity = granularity
            $0.xAxis.labelPosition = labelPosition
            $0.xAxis.drawGridLinesEnabled = drawGridLinesEnabled
            $0.rightAxis.enabled = rightAxisEnabled
            $0.drawMarkers = drawMarkers
            $0.dragEnabled = dragEnabled
            $0.pinchZoomEnabled = pinchZoomEnabled
            $0.doubleTapToZoomEnabled = doubleTapToZoomEnabled
            $0.highlightPerTapEnabled = highlightPerTapEnabled
        }
    }
    
    
    func getLineChartDataSet(
        entries: [String : [ChartDataEntry]],
        chartType: LineChartType,
        dateType: LineChartDateType
    ) -> [LineChartDataSet] {
        var chartDataSets: [LineChartDataSet] = []
        
        let graphColor = getGraphColor(chartType, dateType)
        let sortedKeys = getSortedKeys(entries, chartType)
        
        for (graphIdx, key) in sortedKeys.enumerated() {
            guard let entry = entries[key] else { continue }
            
            let label = getLabel(key, chartType)
            let chartDataSet = LineChartDataSet(entries: entry, label: label)

            setLineChartDataSet(chartDataSet, graphColor[graphIdx], chartType)
            
            chartDataSets.append(chartDataSet)
        }
        
        return chartDataSets
    }

    
    private func getSortedKeys(
        _ entries: [String : [ChartDataEntry]],
        _ chartType: LineChartType
    ) -> [String] {
        switch chartType {
        case .STRESS:
            return ["sns", "pns"]
        case .BPM, .HRV, .SPO2, .BREATHE:
            return entries.keys.sorted()
        }
    }
    
    private func getLabel(
        _ key: String,
        _ chartType: LineChartType
    ) -> String {
        switch chartType {
        case .BPM, .HRV, .SPO2, .BREATHE:
            return dateTime.changeDateFormat(key, false)
        case .STRESS:
            return key
        }
    }
    
    private func getColor(for date: String, from colors: [UIColor]) -> UIColor? {
        guard !colors.isEmpty else { return nil }
        let hash = date.hash
        let index = abs(hash) % colors.count
        return colors[index]
    }
    
    private func setLineChartDataSet(
        _ chartDataSet: LineChartDataSet,
        _ color: NSUIColor,
        _ type: LineChartType
    ) {
        let numberFormatter = NumberFormatter()
        var fractionDigits = 0
        
        switch type {
        case .BPM, .HRV:
            chartDataSet.lineWidth = 0.7
        case .STRESS:
            chartDataSet.lineWidth = 1.2
            numberFormatter.numberStyle = .decimal
            fractionDigits = 1
        case .SPO2:
            chartDataSet.lineWidth = 1.2
            numberFormatter.numberStyle = .decimal
            fractionDigits = 1
        case .BREATHE:
            chartDataSet.lineWidth = 0.7
        }
    
        // value formatter
        numberFormatter.minimumFractionDigits = fractionDigits
        numberFormatter.maximumFractionDigits = fractionDigits
        numberFormatter.locale = Locale.current
        
        let valuesNumberFormatter = ChartValueFormatter(numberFormatter: numberFormatter)
        chartDataSet.valueFormatter = valuesNumberFormatter
        
        chartDataSet.drawValuesEnabled = type != .SPO2 ? true : false
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.setColor(color)
        chartDataSet.mode = .linear
    }
    
    private func sortedDictionary(_ dateChartDict: [String : LineChartDataSet]) -> [LineChartDataSet] {
        var chartDataSets: [LineChartDataSet] = []
        
        let sortedDates = dateChartDict.keys.sorted()
        
        for date in sortedDates {
            if let chartDataSet = dateChartDict[date] {
                chartDataSets.append(chartDataSet)
            }
        }
        
        return chartDataSets
    }
    
    func showChart(
        lineChart: LineChartView,
        lineChartModel: LineChartModel
    ) -> Bool {
        // 1. entries
        guard let entries = lineChartModel.entries else {
            return false // noData
        }
        
        // 2. chart data sets
        let chartDataSets = getLineChartDataSet(
            entries: entries,
            chartType: lineChartModel.chartType,
            dateType: lineChartModel.dateType
        )
        
        // 3. line chart data
        let lineChartData = LineChartData(dataSets: chartDataSets)
        
        // 4. set line chart
        setLineChart(
            lineChart: lineChart,
            chartData: lineChartData,
            chartModel: lineChartModel
        )
        
        // 5. show chart
        lineChart.setVisibleXRangeMaximum(1000)
        lineChart.data?.notifyDataChanged()
        lineChart.notifyDataSetChanged()
        lineChart.moveViewToX(0)
        
        chartZoomOut(lineChart)
        
        return true
    }
    
    private func setLineChart(
        lineChart: LineChartView,
        chartData: LineChartData,
        chartModel: LineChartModel
    ) {
        let timeTable = chartModel.timeTable.map { String($0.dropLast(3)) } // remove second
        
        lineChart.leftAxis.labelCount = 6           // y label default count
        lineChart.leftAxis.removeAllLimitLines()    // remove limit line
        
        switch chartModel.chartType {
        case .BPM, .HRV:
            guard let limitLines = getLimitLines(chartModel) else { return }
            addLimitLine(to: lineChart,limitLines: limitLines)
            
            lineChart.leftAxis.axisMaximum = 200
            lineChart.leftAxis.axisMinimum = chartModel.chartType == .BPM ? 40 : 0
            
        case .STRESS:
            guard let limitLines = getLimitLines(chartModel) else { return }
            addLimitLine(to: lineChart,limitLines: limitLines)
            
            lineChart.leftAxis.axisMaximum = 100
            lineChart.leftAxis.axisMinimum = 0
            
        case .SPO2:
            lineChart.leftAxis.resetCustomAxisMax()
            lineChart.leftAxis.resetCustomAxisMin()

            // y label count
            if let axisMax = lineChart.leftAxis.axisMaximum as Double?,
               let axisMin = lineChart.leftAxis.axisMinimum as Double? {
                let labelCount = Int((axisMax - axisMin) / 0.5) + 1
                lineChart.leftAxis.labelCount = labelCount
            }
            
        case .BREATHE:
            lineChart.leftAxis.resetCustomAxisMax()
            lineChart.leftAxis.resetCustomAxisMin()
        }
        

        lineChart.data = chartData
        lineChart.leftAxis.granularity = chartModel.chartType != .SPO2 ? 1 : 0.5
        lineChart.leftAxis.granularity = 1
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeTable)
    }
    
    
    private func getLimitLines(_ chartModel: LineChartModel) -> [LimitLineData]? {
        switch chartModel.chartType {
        case .BPM, .HRV:
            guard let standardDeviationValue = chartModel.standardDeviationValue,
                  let average = chartModel.stats?.average else { return nil }
            
            let topLimitLine = LimitLineData(
                limit: average + standardDeviationValue,
                color: UIColor.MY_BLUE,
                label: "unit_standard_deviation_eng".localized(),
                width: 3.0
            )
            
            let bottomLimitLine = LimitLineData(
                limit: average - standardDeviationValue,
                color: UIColor.MY_BLUE,
                label: "unit_standard_deviation_eng".localized(),
                width: 3.0
            )
            
            let middleLimitLine = LimitLineData(
                limit: average,
                color: UIColor.MY_ORANGE,
                label: "unit_avg_cap".localized(),
                width: 3.0
            )
            
            return [topLimitLine, bottomLimitLine, middleLimitLine]
        case .STRESS:
            return [
                // low
                LimitLineData(limit: 60, color: UIColor.MY_SKY),
                LimitLineData(limit: 40, color: UIColor.MY_SKY),
                
                // high
                LimitLineData(limit: 80, color: UIColor.MY_LIGHT_PINK),
                LimitLineData(limit: 20, color: UIColor.MY_LIGHT_PINK)
            ]
            
        default:
            return nil
        }
    }
    
    
    private func addLimitLine(
        to lineChart: LineChartView,
        limitLines: [LimitLineData]
    ) {
        limitLines.forEach { addLimitLine in
            let limitLine = ChartLimitLine(
                limit: addLimitLine.limit,
                label: addLimitLine.label
            )
            
            let dashLengths = [addLimitLine.length, addLimitLine.space, addLimitLine.offset]
            
            limitLine.lineWidth = addLimitLine.width
            limitLine.lineColor = addLimitLine.color
            limitLine.lineDashLengths = dashLengths
            limitLine.labelPosition = .rightTop
            
            // text
            limitLine.valueFont = UIFont.boldSystemFont(ofSize: addLimitLine.fontSize)
            limitLine.valueTextColor = addLimitLine.color
            
            // add
            lineChart.leftAxis.addLimitLine(limitLine)
        }
    }
    
    private func chartZoomOut(_ lineChart: LineChartView) {
        for _ in 0..<20 {
            lineChart.zoomOut()
        }
    }
    
    private func getGraphColor(
        _ chartType: LineChartType,
        _ dateType: LineChartDateType
    ) -> [UIColor] {
        switch chartType {
        case .BPM, .HRV, .SPO2, .BREATHE:
            switch (dateType) {
            case .TODAY:
                return [NSUIColor.MY_RED]
            case .TWO_DAYS:
                return [NSUIColor.MY_RED, NSUIColor.GRAPH_BLUE]
            case .THREE_DAYS:
                return [NSUIColor.MY_RED, NSUIColor.GRAPH_BLUE, NSUIColor.GRAPH_GREEN]
            }
            
        case .STRESS:
            return [NSUIColor.GRAPH_RED, NSUIColor.GRAPH_BLUE]
        }
    }
}


class ChartValueFormatter: NSObject, ValueFormatter {
    private var numberFormatter: NumberFormatter?
    
    init(numberFormatter: NumberFormatter) {
        self.numberFormatter = numberFormatter
    }

    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        guard let numberFormatter = numberFormatter
            else {
                return ""
        }
        return numberFormatter.string(for: value)!
    }
}
