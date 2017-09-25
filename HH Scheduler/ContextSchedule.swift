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
        public var name: String
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

    private var numDays: Int
    private var numMods: Int
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
        numDays = 0
        numMods = 0
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
        let isWeekend = Calendar.current.isDateInWeekend(testDate)
        return !isHoliday(testDate) && !isWeekend && isInSchoolYear(testDate)
    }

    public func isScheduledDay(_ testDate: Date) -> Bool {
        let isScheduleless = weirdDays.contains { $0.date.dayCompare(testDate) == .orderedSame && $0.scheduleless }
        return isSchoolDay(testDate) && !isScheduleless
    }

    public func isWeirdDay(_ testDate: Date) -> Bool {
        return weirdDays.contains { $0.date.dayCompare(testDate) == .orderedSame }
    }

    public func isHoliday(_ testDate: Date) -> Bool {
        return holidays.contains { $0.dayCompare(testDate) == .orderedSame }
    }

    public func isInSchoolYear(_ testDate: Date) -> Bool {
        return firstDay.dayCompare(testDate) != .orderedDescending && lastDay.dayCompare(testDate) != .orderedAscending
    }

    public func getNextSchoolDay(_ date: Date, scheduled: Bool = false, forceNext: Bool = false) -> Date? {
        var testDate = date

        if forceNext {
            testDate = Calendar.current.date(byAdding: .day, value: 1, to: testDate)!
        }

        while !(isSchoolDay(testDate) && (!scheduled || isScheduledDay(testDate))) {
            testDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!

            if testDate.dayCompare(lastDay) == .orderedDescending {
                return nil
            }
        }

        return testDate
    }

    public func getCycleDay(_ cycleDate: Date) -> Int {
        var bestLandmark = (firstDay, 0)

        guard isScheduledDay(cycleDate) else { return -1 }

        for landmark in landmarks {
            if landmark.0 > bestLandmark.0 && landmark.0.dayCompare(cycleDate) != .orderedDescending {
                bestLandmark = landmark
            }
        }

        while bestLandmark.0.dayCompare(cycleDate) == .orderedAscending {
            if isScheduledDay(bestLandmark.0) {
                bestLandmark.1 += 1
            }

            bestLandmark.0 = Calendar.current.date(byAdding: .day, value: 1, to: bestLandmark.0)!
        }

        let cycleDay = bestLandmark.1 % numDays

        return cycleDay
    }

    public func getStartTime(_ date: Date) -> Date? {
        let cycleDay = getCycleDay(date)
        guard cycleDay >= 0 else { return nil }
        let isDDay = cycleDay == 3
        let isWednesday = Calendar.current.dateComponents([.weekday], from: date).weekday == 4
        return getWeirdDay(date)?.startTime ?? ((isDDay || isWednesday) ? lateStartTime : regStartTime)
    }

    public func getEndTime(_ date: Date) -> Date? {
        let cycleDay = getCycleDay(date)
        guard cycleDay >= 0 else { return nil }
        let isDDay = cycleDay == 3
        let isWednesday = Calendar.current.dateComponents([.weekday], from: date).weekday == 4
        return getWeirdDay(date)?.endTime ?? ((isDDay || isWednesday) ? lateEndTime : regEndTime)
    }

    public func getBlocks(_ date: Date, from personalSchedule: Schedule) -> [ContextScheduleBlock] {
        guard isScheduledDay(date) else { return [] }

        let cycleDay = getCycleDay(date)

        let isDDay = cycleDay == 3
        let isWednesday = Calendar.current.dateComponents([.weekday], from: date).weekday == 4
        let isLateDay = isDDay || isWednesday
        let weirdDay = getWeirdDay(date)
        let weirdBlockTimes = weirdDay?.blockIndexes?.map { $0.0 }
        let blockTimes = weirdBlockTimes ?? (isLateDay ? lateModTimes : regModTimes)
        let weirdBlockIndexes = weirdDay?.blockIndexes?.map { $0.1 }
        let blockIndexes = weirdBlockIndexes ?? [Int](0..<numMods)

        guard blockTimes.count == blockIndexes.count else { return [] }

        var blocks = [ContextScheduleBlock]()
        let numBlocks = blockTimes.count
        let endTime = getEndTime(date)!
        for b in 0..<numBlocks {
            let blockStart = blockTimes[b]
            let blockEnd = (b == numBlocks - 1) ? endTime : blockTimes[b + 1]
            let blockIndex = blockIndexes[b]
            let baseBlock = (blockIndex < 0) ? specialBlocks[-(blockIndex + 1)] : personalSchedule.getBlock(day: cycleDay, mod: blockIndex)

            let block = ContextScheduleBlock(name: baseBlock.name, classID: baseBlock.classID, color: baseBlock.color, startTime: blockStart, endTime: blockEnd, from: self, mod: (blockIndex >= 0) ? blockIndex : nil)

            blocks.append(block)
        }

        return blocks
    }

    public func getWeirdDayName(_ testDate: Date) -> String? {
        return weirdDays.first(where: { $0.date.dayCompare(testDate) == .orderedSame })?.name
    }

    public func refreshContext(jsonURL: URL) {
        guard let data = try? Data(contentsOf: jsonURL) else { print("Failed to get data"); return }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else { print("Failed to parse data"); return }
        guard let jsonDict = jsonObject as? [String: Any] else { return }

        guard let numDays = jsonDict["NumDays"] as? Int else { return }
        guard let numMods = jsonDict["NumMods"] as? Int else { return }

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
            guard let name = weirdDayObject["name"] as? String else { return }
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
                        let specialBlock = ScheduleBlock(name: mod[1], classID: blockIndex, color: hh_tint)

                        blockIndexes?.append((blockTime, blockIndex))
                        specialBlocks.append(specialBlock)
                    }
                }
            }

            let weirdDay = WeirdDay(name: name, date: weirdDayDate, startTime: startTime, endTime: endTime, scheduleless: scheduleless, blockIndexes: blockIndexes)

            weirdDays.append(weirdDay)
        }

        self.numDays = numDays
        self.numMods = numMods
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

    private func getWeirdDay(_ date: Date) -> WeirdDay? {
        return weirdDays.first(where: { $0.date.dayCompare(date) == .orderedSame })
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
