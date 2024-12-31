//
//  DateCalculator.swift
//
//
//  Created by KHJ on 6/25/24.
//

import Foundation


public class DateCalculator {
    public enum DateTimeType {
        case date; case time; case dateTime
    }
    
    private let dateFormatter: DateFormatter
    private let calendar: Calendar
    
    
    public init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        self.calendar = Calendar.current
    }
    
    public func getDateFormatter(_ dateType : DateTimeType) -> DateFormatter {
        dateFormatter.dateFormat = getFormatter(dateType)
        
        return dateFormatter
    }
    
    
    public func getCurrentDateTime(_ dateType : DateTimeType ) -> String {
        let now = Date()
        
        dateFormatter.dateFormat = getFormatter(dateType)
        
        return dateFormatter.string(from: now)
    }
    
    
    public func getFormatter(_ dateTimeType : DateTimeType) -> String {
        switch (dateTimeType) {
        case .dateTime:
            return "yyyy-MM-dd HH:mm:ss"
        case .date:
            return "yyyy-MM-dd"
        case .time:
            return "HH:mm:ss"
        }
    }
    
    public func dateCalculate(
        _ date: String,
        _ day: Int,
        _ shouldAdd: Bool,
        _ type: Calendar.Component
    ) -> String {
        dateFormatter.dateFormat = getFormatter(.date)
        
        guard let inputDate = dateFormatter.date(from: date) else { return date }
        
        let dayValue = shouldAdd ? day : -day
        
        if let calcDate = calendar.date(byAdding: type, value: dayValue, to: inputDate) {
            return dateFormatter.string(from: calcDate)
        }
        
        return date
    }
}
