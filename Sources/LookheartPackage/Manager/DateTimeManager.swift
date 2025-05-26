//
//  DateTimeManager.swift
//  LOOKHEART 100
//
//  Created by KHJ on 4/24/25.
//

import Foundation


public final class DateTimeManager {
    public static let shared = DateTimeManager()
    
    private let calendar = Calendar.current
    
    private let utcDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    private let utcDateTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()
    
    private let utcHourFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = "HH"
        return df
    }()
    
    private let localDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.locale = .current
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    private let localDateTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.locale = .current
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    init() { }
    
    
    // MARK: - UTC
    public func getCurrentUtcDate() -> String {
        let now = Date()
        return utcDateFormatter.string(from: now)
    }
    
    public func getCurrentUtcDateTime() -> String {
        let now = Date()
        return utcDateTimeFormatter.string(from: now)
    }
    
    public func getCurrentUtcHour() -> String {
        let now = Date()
        return utcHourFormatter.string(from: now)
    }
    
    
    // MARK: - Local
    public func getCurrentLocalDate() -> String {
        let now = Date()
        return localDateFormatter.string(from: now)
    }
    
    public func getCurrentLocalDateTime() -> String {
        let now = Date()
        return localDateTimeFormatter.string(from: now)
    }
    

    // MARK: - TimeZone
    public func getTimeZone() -> String {
        let currentTimeZone = TimeZone.current
        let utcOffsetInSeconds = currentTimeZone.secondsFromGMT()
        let hours = abs(utcOffsetInSeconds) / 3600
        let minutes = (abs(utcOffsetInSeconds) % 3600) / 60
        let offsetString = String(format: "%@%02d:%02d", utcOffsetInSeconds >= 0 ? "+" : "-", hours, minutes)
        return offsetString
    }
    
    public func getIdentifier() -> String {
        let currentTimeZone = TimeZone.current
        let identifier = currentTimeZone.identifier     // 현재 국가, 도시
        return identifier
    }
    
    public func getCountryCode() -> String {
        let currentCountryCode = Locale.current.regionCode ?? "Unknown"  // "US", "KR" 등
        return currentCountryCode
    }
    
    public func getAllTimeZoneData() -> String {
        let timeZone = getTimeZone()
        let identifier = getIdentifier()
        let countryCode = getCountryCode()
        return "\(timeZone)/\(identifier)/\(countryCode)"   // +09:00/Asia/Seoul/KR
    }
    
    
    // MARK: - Calculate
    public func getFormattedDateString(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    public func getFormattedLocalDate(_ dateStr: String) -> Date? {
        return localDateFormatter.date(from: dateStr)
    }
    
    public func getFormattedLocalDateString(_ dateStr: Date) -> String {
        return localDateFormatter.string(from: dateStr)
    }
    
    public func daysInMonth(from dateStr: String) -> Int? {
        guard let date = localDateFormatter.date(from: dateStr) else {
            return nil
        }
        
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: date) else {
            return nil
        }
        
        return range.count
    }
    
    // adjustDate("2025-04-21", offset: 1 or -1, component: .day)
    public func adjustDate(
        _ dateString: String,
        offset: Int,
        component: Calendar.Component
    ) -> String? {
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        
        guard let newDate = Calendar.current.date(
            byAdding: component,
            value: offset,
            to: date
        ) else {
            return nil
        }
        
        return dateFormatter.string(from: newDate)
    }
    
    
    public func checkLocalDate(
      utcDateTime: String?,
      localDate: String? = nil
    ) -> Bool {
      guard let utcDateTime = utcDateTime else { return false }
        
      guard let utcDateTime = utcDateTimeFormatter.date(from: utcDateTime) else {
        return false
      }
        
      let targetLocalDateStr: String = {
        if let local = localDate, !local.isEmpty {
          return local
        } else {
            return localDateFormatter.string(from: Date())
        }
      }()
        
      guard let localDateAtMidnight = localDateFormatter.date(from: targetLocalDateStr) else {
        return false
      }

      // 시작(00:00)과 다음날 시작(다음날 00:00)
      let calendar = Calendar.current
      let startOfDay = calendar.startOfDay(for: localDateAtMidnight)
      guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
        return false
      }

      // utcDateTime이 localDate 시작 ~ 다음날에 속하는지 비교
      return (utcDateTime >= startOfDay) && (utcDateTime < startOfNextDay)
    }
    
    
    
    public func localDateStartToUtcDateString(
        _ localDateStr: String
    ) -> String? {
        // 1) 로컬 포맷터: "yyyy-MM-dd" → Date(로컬 00:00)
        guard let localMidnight = localDateFormatter.date(from: localDateStr) else {
            return nil
        }
        
        // 2) UTC 포맷터: Date → "yyyy-MM-dd" (UTC 기준)
        return utcDateFormatter.string(from: localMidnight)
    }
    
    
    public func localDateEndToUtcDateString(
        _ localDateStr: String
    ) -> String? {
        // 1) 로컬 포맷터: "yyyy-MM-dd" → Date(로컬 00:00)
        guard let localMidnight = localDateFormatter.date(from: localDateStr) else {
            return nil
        }

        // 2) Calendar를 이용해 '다음 날 00:00' 구하기
        guard let nextMidnight = calendar.date(byAdding: .day, value: 1, to: localMidnight) else {
            return nil
        }

        // 3) UTC 포맷터: Date → "yyyy-MM-dd" (UTC 기준)
        return utcDateFormatter.string(from: nextMidnight)
    }
    
    
    public func convertUtcToLocal(utcTimeStr: String) -> String? {
        guard let utcDate = utcDateTimeFormatter.date(from: utcTimeStr) else {
            return nil
        }
        
        return localDateTimeFormatter.string(from: utcDate)
    }
}

