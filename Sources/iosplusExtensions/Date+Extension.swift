//
//  Date+Extension.swift
//
//  Created by Lazar Sidor on 22.02.2022.
//

import Foundation

public extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    static let iso8601noFS = ISO8601DateFormatter()
    static let utcDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.init(identifier: .gregorian)
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
}

public extension Date {
    func toString(dateFormat: String, locale: Locale) -> String {
        // change to a readable time format and change to local time zone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = locale.calendar.timeZone
        dateFormatter.calendar = locale.calendar
        dateFormatter.locale = locale
        let timeStamp = dateFormatter.string(from: self)

        return timeStamp
    }

    // Convert local time to UTC (or GMT)
    func toGlobalTime(locale: Locale) -> Date {
        let timezone = locale.calendar.timeZone
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    // Convert UTC (or GMT) to local time
    func toLocalTime(locale: Locale) -> Date {
        let timezone = locale.calendar.timeZone
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    func utcOffset(locale: Locale) -> Int {
        let distance = self.timeIntervalSince1970 - self.toGlobalTime(locale: locale).timeIntervalSince1970
        let offset = distance / 60
        return Int(offset)
    }
}

public let componentFlags: Set<Calendar.Component> = Set<Calendar.Component>([.year, .month, .day, .weekday, .hour, .minute, .second, .weekOfYear, .weekdayOrdinal])

public extension Date {
    func dateAtStartOfDay(locale: Locale) -> Date {
        var components = locale.calendar.dateComponents(componentFlags, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0

        return locale.calendar.date(from: components)!
    }

    func dateAtStartOfWeek(locale: Locale) -> Date {
        var components = locale.calendar.dateComponents(componentFlags, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.day = components.day! - (((components.weekday! - locale.calendar.firstWeekday) + 7) % 7)

        return locale.calendar.date(from: components)!
    }

    func dateAtStartOfMonth(locale: Locale) -> Date {
        var components = locale.calendar.dateComponents(componentFlags, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.day = 1
        components.month = self.month(locale: locale)

        return locale.calendar.date(from: components)!
    }

    func dateAtEndOfMonth(locale: Locale) -> Date {
        let range = locale.calendar.range(of: .day, in: .month, for: self)!

        var components = locale.calendar.dateComponents(componentFlags, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.day = range.count
        components.month = self.month(locale: locale)

        return locale.calendar.date(from: components)!
    }

    func dateAtEndOfDay(locale: Locale) -> Date {
        var components = locale.calendar.dateComponents(componentFlags, from: self)
        components.hour = 23
        components.minute = 59
        components.second = 59

        return locale.calendar.date(from: components)!
    }

    func addingMinutes(_ min: Int, locale: Locale) -> Date {
        var components = DateComponents()
        components.minute = min

        return locale.calendar.date(byAdding: components, to: self) ?? self
    }

    func addingSeconds(_ sec: Int, locale: Locale) -> Date {
        var components = DateComponents()
        components.second = sec

        return locale.calendar.date(byAdding: components, to: self) ?? self
    }

    func addingDays(_ days: Int, locale: Locale) -> Date {
        var components = DateComponents()
        components.day = days

        return locale.calendar.date(byAdding: components, to: self) ?? self
    }

    func addingMonths(_ months: Int, locale: Locale) -> Date {
        var components = DateComponents()
        components.month = months

        return locale.calendar.date(byAdding: components, to: self) ?? self
    }

    func addingYears(_ years: Int, locale: Locale) -> Date {
        var components = DateComponents()
        components.year = years

        return locale.calendar.date(byAdding: components, to: self) ?? self
    }

    func subtractingYears(_ years: Int, locale: Locale) -> Date {
        return addingYears(-years, locale: locale)
    }

    func subtractingMinutes(_ min: Int, locale: Locale) -> Date {
        return addingMinutes(-min, locale: locale)
    }

    func subtractingMonths(_ months: Int, locale: Locale) -> Date {
        return addingMonths(-months, locale: locale)
    }

    func subtractingDays(_ days: Int, locale: Locale) -> Date {
        return addingDays(-days, locale: locale)
    }

    func date(with day: Int, locale: Locale) -> Date {
        var components = locale.calendar.dateComponents(componentFlags, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.day = day
        components.month = self.month(locale: locale)

        return locale.calendar.date(from: components)!
    }

    static func date(with day: Int, month: Int, year: Int, locale: Locale) -> Date {
        var components = locale.calendar.dateComponents(componentFlags, from: Date())
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.day = day
        components.month = month
        components.year = year

        return locale.calendar.date(from: components)!
    }

    static func calculateWeekStart(date: Date, locale: Locale) -> Date {
        let startOptions = NSCalendar.Options.matchPreviousTimePreservingSmallerUnits
        let sun = 1
        let date = date.dateAtStartOfWeek(locale: locale).subtractingDays(7, locale: locale)
        let startDate = ((locale.calendar as NSCalendar).nextDate(after: date, matching: NSCalendar.Unit.weekday, value: sun, options: startOptions))!
        return startDate
    }

    // swiftlint:disable large_tuple
    static func secondsToHoursMinutesSeconds (seconds: TimeInterval) -> (Int, Int, Int) {
        return (Int(seconds) / 3600, (Int(seconds) % 3600) / 60, (Int(seconds) % 3600) % 60)
    }

    // MARK: - Per components
    func scd_dayOfWeek(locale: Locale) -> Int? {
        let components = locale.calendar.dateComponents(componentFlags, from: self)
        return components.weekday
    }

    func numberOfDaysInMonth(locale: Locale) -> Int {
        let components = locale.calendar.dateComponents(componentFlags, from: self)
        let date = locale.calendar.date(from: components)!
        let range = locale.calendar.range(of: .day, in: .month, for: date)!

        return range.count
    }

    func numberOfWeeks(since date: Date, locale: Locale) -> Int? {
        let components = locale.calendar.dateComponents([.weekOfYear], from: self, to: date)
        return components.weekOfYear
    }

    static func numberOfDays(in month: Int, locale: Locale) -> [Int] {
        let currentDate = Date()
        var date = Date.date(with: currentDate.day(), month: month, year: currentDate.year(locale: locale), locale: locale)
        if date < currentDate {
            date = Date.date(with: currentDate.day(), month: month, year: currentDate.year(locale: locale) + 1, locale: locale)
        }

        return Array(1...date.numberOfDaysInMonth(locale: locale))
    }

    // MARK: - Checks
    func isOddWeek(locale: Locale) -> Bool {
        let fourth1970 = Date.date(with: 4, month: 1, year: 1970, locale: locale)
        let weeksSince1970 = self.numberOfWeeks(since: fourth1970, locale: locale)

        return weeksSince1970! % 2 == 0
    }

    func isEarlierThanDate(aDate: Date) -> Bool {
        return self.compare(aDate) == .orderedAscending
    }

    func isLaterThanDate(aDate: Date) -> Bool {
        return self.compare(aDate) == .orderedDescending
    }

    func isEqualOrEarlierThanDate(aDate: Date) -> Bool {
        return self.compare(aDate) == .orderedAscending || self.compare(aDate) == .orderedSame
    }

    func isEqualOrLaterThanDate(aDate: Date) -> Bool {
        return self.compare(aDate) == .orderedDescending || self.compare(aDate) == .orderedSame
    }

    func isEqualOrEarlierThanDateIgnoringTime(aDate: Date, locale: Locale) -> Bool {
        return self.dateAtStartOfDay(locale: locale).compare(aDate.dateAtStartOfDay(locale: locale)) == .orderedAscending || self.dateAtStartOfDay(locale: locale).compare(aDate.dateAtStartOfDay(locale: locale)) == .orderedSame
    }

    func isEqualOrLaterThanDateIgnoringTime(aDate: Date, locale: Locale) -> Bool {
        return self.dateAtStartOfDay(locale: locale).compare(aDate.dateAtStartOfDay(locale: locale)) == .orderedDescending || self.dateAtStartOfDay(locale: locale).compare(aDate.dateAtStartOfDay(locale: locale)) == .orderedSame
    }

    func isEqualToDateIgnoringTime(aDate: Date, locale: Locale) -> Bool {
        return self.dateAtStartOfDay(locale: locale).compare(aDate.dateAtStartOfDay(locale: locale)) == .orderedSame
    }

    // MARK: - Decomposing Dates

    func hour() -> Int {
        let components = Calendar.current.dateComponents(componentFlags, from: self)
        return components.hour ?? 0
    }

    func minute() -> Int {
        let components = Calendar.current.dateComponents(componentFlags, from: self)
        return components.minute ?? 0
    }

    func seconds() -> Int {
        let components = Calendar.current.dateComponents(componentFlags, from: self)
        return components.second ?? 0
    }

    func day() -> Int {
        let components = Calendar.current.dateComponents(componentFlags, from: self)
        return components.day ?? 0
    }

    func month(locale: Locale) -> Int {
        let components = locale.calendar.dateComponents(componentFlags, from: self)
        return components.month ?? 0
    }

    func week(locale: Locale) -> Int {
        let components = locale.calendar.dateComponents(componentFlags, from: self)
        return components.weekOfMonth ?? 0
    }

    func weekday(locale: Locale) -> Int {
        let components = locale.calendar.dateComponents(componentFlags, from: self)
        return components.weekday ?? 0
    }

    func nthWeekday(locale: Locale) -> Int {
        let components = locale.calendar.dateComponents(componentFlags, from: self)
        return components.weekdayOrdinal ?? 0
    }

    func year(locale: Locale) -> Int {
        let components = locale.calendar.dateComponents(componentFlags, from: self)
        return components.year ?? 0
    }

    // Close

    func closestFutureDate(_ dates: [Date]) -> Date? {
        let sortedDates = dates.sorted { $0 < $1 }
        return sortedDates.first { $0 > self }
    }

    func closestPastDate(_ dates: [Date]) -> Date? {
        let sortedDates = dates.sorted { $0 < $1 }
        return sortedDates.first { $0 < self }
    }
}
