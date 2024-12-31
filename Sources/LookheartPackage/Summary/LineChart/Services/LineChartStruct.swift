//
//  File.swift
//  
//
//  Created by KHJ on 12/2/24.
//

import Foundation
import UIKit
import DGCharts

struct LimitLineData {
    let limit: Double
    let color: UIColor

    var label: String = ""
    var width: CGFloat = 2.0
    
    var length: CGFloat = 3.0
    var space: CGFloat = 2.0
    var offset: CGFloat = 0.0
    
    var fontSize: CGFloat = 10
}


struct ChartStatistics {
    var maxValue: Double = -Double.greatestFiniteMagnitude
    var minValue: Double = Double.greatestFiniteMagnitude
    var sumValue: Double = 0.0
    var count: Int = 0
    
    mutating func update(with value: Double) {
        maxValue = max(maxValue, value)
        minValue = min(minValue, value)
        sumValue += value
        count += 1
    }
    
    var average: Double {
        return count > 0 ? sumValue / Double(count) : 0.0
    }
}

struct StressChartStatistics {
    var pns: ChartStatistics = ChartStatistics()
    var sns: ChartStatistics = ChartStatistics()
}
