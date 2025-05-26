//
//  Untitled.swift
//  LookheartPackage
//
//  Created by KHJ on 4/28/25.
//


enum DayOfWeek: CaseIterable {
    case MONDAY
    case TUESDAY
    case WEDNESDAY
    case THURSDAY
    case FRIDAY
    case SATURDAY
    case SUNDAY
    
    var name: String {
        switch self {
            
        case .MONDAY:
            return "MON"
        case .TUESDAY:
            return "TUE"
        case .WEDNESDAY:
            return "WED"
        case .THURSDAY:
            return "THU"
        case .FRIDAY:
            return "FRI"
        case .SATURDAY:
            return "SAT"
        case .SUNDAY:
            return "SUN"
        }
    }
}
