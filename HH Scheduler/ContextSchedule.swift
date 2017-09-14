//
//  ContextSchedule.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/13/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import Foundation

class ContextSchedule {
    private struct WeirdDay {
        public var date: Date
        public var startTime: Date?
        public var endTime: Date?
        public var scheduleless: Bool
        public var blockIndexes: [(Date, Int)]?
    }

    private static let timeFormatter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "hh:mmaa"
        a.locale = Locale(identifier: "en_US")
        a.timeZone = TimeZone(abbreviation: "CST")

        return a
    }()
    private static let dateFormatter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "dd MMMM yyyy"
        a.locale = Locale(identifier: "en_US")
        a.timeZone = TimeZone(abbreviation: "CST")

        return a
    }()

    public var personalSchedule: ScheduleDataSource?

    private var regStartTime: Date
    private var regEndTime: Date
    private var lateStartTime: Date
    private var lateEndTime: Date
    private var firstDay: Date
    private var lastDay: Date
    private var regModTimes: [Date]
    private var lateModTimes: [Date]
    private var landmarks: [(Date, Int)]
    private var holidays: [Date]
    private var weirdDays: [WeirdDay]
    private var specialBlocks: [ScheduleBlock]

    public init(jsonURL: URL) {
        regStartTime = Date(timeIntervalSince1970: 0)
        regEndTime = Date(timeIntervalSince1970: 0)
        lateStartTime = Date(timeIntervalSince1970: 0)
        lateEndTime = Date(timeIntervalSince1970: 0)
        firstDay = Date(timeIntervalSince1970: 0)
        lastDay = Date(timeIntervalSince1970: 0)
        regModTimes = [Date]()
        lateModTimes = [Date]()
        landmarks = [(Date, Int)]()
        holidays = [Date]()
        weirdDays = [WeirdDay]()
        specialBlocks = [ScheduleBlock]()

        refreshContext(jsonURL: jsonURL)
    }

    public func isSchoolDay(_ testDate: Date) -> Bool {
        let isHoliday = holidays.contains { $0.dayCompare(testDate) == .orderedSame }
        let isWeekend = Calendar.current.isDateInWeekend(testDate)
        let inSchoolYear = firstDay.dayCompare(testDate) != .orderedDescending && lastDay.dayCompare(testDate) != .orderedAscending
        return !isHoliday && !isWeekend && inSchoolYear
    }

    public func isScheduledDay(_ testDate: Date) -> Bool {
        let isScheduleless = weirdDays.contains { $0.date.dayCompare(testDate) == .orderedSame && $0.scheduleless }
        return isSchoolDay(testDate) && !isScheduleless
    }

    public func isWeirdDay(_ testDate: Date) -> Bool {
        return weirdDays.contains { $0.date.dayCompare(testDate) == .orderedSame }
    }

    public func getCycleDay(_ cycleDate: Date) -> Int {
        var bestLandmark = (firstDay, 0)

        var date = cycleDate

        while true {
            if isScheduledDay(date) {
                break
            }

            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        }

        for landmark in landmarks {
            if landmark.0 > bestLandmark.0 && landmark.0.dayCompare(date) != .orderedDescending {
                bestLandmark = landmark
            }
        }

        while bestLandmark.0.dayCompare(date) == .orderedAscending {
            if isScheduledDay(bestLandmark.0) {
                bestLandmark.1 += 1
            }

            bestLandmark.0 = Calendar.current.date(byAdding: .day, value: 1, to: bestLandmark.0)!
        }

        let cycleDay = bestLandmark.1 % NUM_DAYS

        return cycleDay
    }

    public func refreshContext(jsonURL: URL) {
        guard let data = try? Data(contentsOf: jsonURL) else { print("Failed to get data"); return }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else { print("Failed to parse data"); return }
        guard let jsonDict = jsonObject as? [String: Any] else { return }

        guard let regStartTimeStr = jsonDict["RegularStartTime"] as? String else { return }
        guard let regStartTime = time(from: regStartTimeStr) else { return }

        guard let regEndTimeStr = jsonDict["RegularEndTime"] as? String else { return }
        guard let regEndTime = time(from: regEndTimeStr) else { return }

        guard let lateStartTimeStr = jsonDict["LateStartTime"] as? String else { return }
        guard let lateStartTime = time(from: lateStartTimeStr) else { return }

        guard let lateEndTimeStr = jsonDict["LateEndTime"] as? String else { return }
        guard let lateEndTime = time(from: lateEndTimeStr) else { return }

        guard let firstDayStr = jsonDict["FirstDay"] as? String else { return }
        guard let firstDay = date(from: firstDayStr) else { return }

        guard let lastDayStr = jsonDict["LastDay"] as? String else { return }
        guard let lastDay = date(from: lastDayStr) else { return }

        guard let regModTimeStrs = jsonDict["RegularModTimes"] as? [String] else { return }
        var regModTimes = [Date]()
        for timeStr in regModTimeStrs {
            guard let modTime = time(from: timeStr) else { return }
            regModTimes.append(modTime)
        }

        guard let lateModTimeStrs = jsonDict["LateModTimes"] as? [String] else { return }
        var lateModTimes = [Date]()
        for timeStr in lateModTimeStrs {
            guard let modTime = time(from: timeStr) else { return }
            lateModTimes.append(modTime)
        }

        guard let landmarkStrs = jsonDict["LandmarkDays"] as? [[String]] else { return }
        var landmarks = [(Date, Int)]()
        for landmark in landmarkStrs {
            guard let calenderDay = date(from: landmark[0]) else { return }
            guard let cycleDayUnicode = landmark[1].unicodeScalars.first?.value else { return }
            let cycleDay = Int(cycleDayUnicode) - 65
            landmarks.append((calenderDay, cycleDay))
        }
        if landmarks.count == 0 { return }

        guard let holidayStrs = jsonDict["Holidays"] as? [String] else { return }
        var holidays = [Date]()
        for holidayStr in holidayStrs {
            guard let holiday = date(from: holidayStr) else { return }
            holidays.append(holiday)
        }

        guard let weirdDayObjects = jsonDict["WeirdSchedules"] as? [[String: Any]] else { return }
        var weirdDays = [WeirdDay]()
        var specialBlocks = [ScheduleBlock]()
        for weirdDayObject in weirdDayObjects {
            guard let weirdDayDateStr = weirdDayObject["date"] as? String else { return }
            guard let weirdDayDate = date(from: weirdDayDateStr) else { return }
            let startTimeStr = weirdDayObject["startTime"] as? String
            let startTime = (startTimeStr != nil) ? time(from: startTimeStr!) : nil
            let endTimeStr = weirdDayObject["endTime"] as? String
            let endTime = (endTimeStr != nil) ? time(from: endTimeStr!) : nil
            let scheduleless = weirdDayObject["scheduleless"] as? Bool ?? false

            var blockIndexes: [(Date, Int)]? = nil
            if let mods = weirdDayObject["mods"] as? [[String]] {
                blockIndexes = [(Date, Int)]()

                for mod in mods {
                    guard let blockTime = time(from: mod[0]) else { return }

                    if mod[1].lowercased().hasPrefix("mod") {
                        guard let modNumber = Int(mod[1].split()[1]) else { return }
                        let blockIndex = modNumber - 1

                        blockIndexes?.append((blockTime, blockIndex))
                    }
                    else {
                        let blockIndex = -(specialBlocks.count + 1)
                        let specialBlock = ScheduleBlock(name: mod[1], color: hh_tint)

                        blockIndexes?.append((blockTime, blockIndex))
                        specialBlocks.append(specialBlock)
                    }
                }
            }

            let weirdDay = WeirdDay(date: weirdDayDate, startTime: startTime, endTime: endTime, scheduleless: scheduleless, blockIndexes: blockIndexes)

            weirdDays.append(weirdDay)
        }

        self.regStartTime = regStartTime
        self.regEndTime = regEndTime
        self.lateStartTime = lateStartTime
        self.lateEndTime = lateEndTime
        self.firstDay = firstDay
        self.lastDay = lastDay
        self.regModTimes = regModTimes
        self.lateModTimes = lateModTimes
        self.landmarks = landmarks
        self.holidays = holidays
        self.weirdDays = weirdDays
        self.specialBlocks = specialBlocks
    }

    private func date(from string: String) -> Date? {
        if let timedDate = ContextSchedule.dateFormatter.date(from: string) {
            return Calendar.current.startOfDay(for: timedDate)
        }

        return nil
    }

    private func time(from string: String) -> Date? {
        if let datedTime = ContextSchedule.timeFormatter.date(from: string) {
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: datedTime)

            return Calendar.current.date(from: dateComponents)
        }

        return nil
    }
}
