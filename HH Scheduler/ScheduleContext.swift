//
//  ContextSchedule.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/13/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import Foundation

class ScheduleContext {
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
    private var specialClasses: [ScheduleClass]
    private var loaded: Bool

    public init() {
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
        specialClasses = [ScheduleClass]()
        loaded = false
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
        guard isScheduledDay(cycleDate) else { return -1 }

        var bestLandmark = landmarks.filter({ $0.0.dayCompare(cycleDate) != .orderedDescending }).sorted(by: { $0.0 < $1.0 }).last!

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

    public func getBlocks(_ date: Date, from personalSchedule: PersonalSchedule) -> [ScheduleBlock] {
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

        var blocks = [ScheduleBlock]()
        let numBlocks = blockTimes.count
        let endTime = getEndTime(date)!
        for b in 0..<numBlocks {
            let blockStart = blockTimes[b]
            let blockEnd = (b == numBlocks - 1) ? endTime : blockTimes[b + 1]
            let blockIndex = blockIndexes[b]

            if blockIndex < 0 {
                let specClass = specialClasses[-(blockIndex + 1)]
                let block = ScheduleBlock(scheduleClass: specClass, startTime: blockStart, endTime: blockEnd, scheduleContext: self, mod: nil)
                blocks.append(block)
            }
            else {
                let classInfo = personalSchedule.getClassInfo(atDay: cycleDay, mod: blockIndex)
                let block = ScheduleBlock(scheduleClass: classInfo, startTime: blockStart, endTime: blockEnd, scheduleContext: self, mod: blockIndex)

                blocks.append(block)
            }
        }

        return blocks
    }

    public func getWeirdDayName(_ testDate: Date) -> String? {
        return weirdDays.first(where: { $0.date.dayCompare(testDate) == .orderedSame })?.name
    }

    @discardableResult
    public func refreshContext(contextData data: Data) -> Bool {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else { return false }
        guard let jsonDict = jsonObject as? [String: Any] else { return false }

        guard let numDays = jsonDict["NumDays"] as? Int else { return false }
        guard let numMods = jsonDict["NumMods"] as? Int else { return false }

        guard let regStartTimeStr = jsonDict["RegularStartTime"] as? String else { return false }
        guard let regStartTime = time(from: regStartTimeStr) else { return false }

        guard let regEndTimeStr = jsonDict["RegularEndTime"] as? String else { return false }
        guard let regEndTime = time(from: regEndTimeStr) else { return false }

        guard let lateStartTimeStr = jsonDict["LateStartTime"] as? String else { return false }
        guard let lateStartTime = time(from: lateStartTimeStr) else { return false }

        guard let lateEndTimeStr = jsonDict["LateEndTime"] as? String else { return false }
        guard let lateEndTime = time(from: lateEndTimeStr) else { return false }

        guard let firstDayStr = jsonDict["FirstDay"] as? String else { return false }
        guard let firstDay = date(from: firstDayStr) else { return false }

        guard let lastDayStr = jsonDict["LastDay"] as? String else { return false }
        guard let lastDay = date(from: lastDayStr) else { return false }

        guard let regModTimeStrs = jsonDict["RegularModTimes"] as? [String] else { return false }
        var regModTimes = [Date]()
        for timeStr in regModTimeStrs {
            guard let modTime = time(from: timeStr) else { return false }
            regModTimes.append(modTime)
        }

        guard let lateModTimeStrs = jsonDict["LateModTimes"] as? [String] else { return false }
        var lateModTimes = [Date]()
        for timeStr in lateModTimeStrs {
            guard let modTime = time(from: timeStr) else { return false }
            lateModTimes.append(modTime)
        }

        guard let landmarkStrs = jsonDict["LandmarkDays"] as? [[String]] else { return false }
        var landmarks = [(Date, Int)]()
        for landmark in landmarkStrs {
            guard let calenderDay = date(from: landmark[0]) else { return false }
            guard let cycleDayUnicode = landmark[1].unicodeScalars.first?.value else { return false }
            let cycleDay = Int(cycleDayUnicode) - 65
            landmarks.append((calenderDay, cycleDay))
        }
        if landmarks.count == 0 { return false }

        guard let holidayStrs = jsonDict["Holidays"] as? [String] else { return false }
        var holidays = [Date]()
        for holidayStr in holidayStrs {
            guard let holiday = date(from: holidayStr) else { return false }
            holidays.append(holiday)
        }

        guard let weirdDayObjects = jsonDict["WeirdSchedules"] as? [[String: Any]] else { return false }
        var weirdDays = [WeirdDay]()
        var specialClasses = [ScheduleClass]()
        for weirdDayObject in weirdDayObjects {
            guard let name = weirdDayObject["name"] as? String else { return false }
            guard let weirdDayDateStr = weirdDayObject["date"] as? String else { return false }
            guard let weirdDayDate = date(from: weirdDayDateStr) else { return false }
            let startTimeStr = weirdDayObject["startTime"] as? String
            let startTime = (startTimeStr != nil) ? time(from: startTimeStr!) : nil
            let endTimeStr = weirdDayObject["endTime"] as? String
            let endTime = (endTimeStr != nil) ? time(from: endTimeStr!) : nil
            let scheduleless = (weirdDayObject["scheduleless"] as? Bool) ?? (weirdDayObject["mods"] as? [[String]] == nil)

            var blockIndexes: [(Date, Int)]? = nil
            if let mods = weirdDayObject["mods"] as? [[String]] {
                blockIndexes = [(Date, Int)]()

                for mod in mods {
                    guard let blockTime = time(from: mod[0]) else { return false }

                    if mod[1].lowercased().hasPrefix("mod") {
                        guard let modNumber = Int(mod[1].split()[1]) else { return false }
                        let blockIndex = modNumber - 1

                        blockIndexes?.append((blockTime, blockIndex))
                    }
                    else {
                        let blockIndex = -(specialClasses.count + 1)
                        let specialClass = ScheduleClass(classID: blockIndex, classIndex: -1, name: mod[1], color: hhTint)

                        blockIndexes?.append((blockTime, blockIndex))
                        specialClasses.append(specialClass)
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
        self.specialClasses = specialClasses
        self.loaded = true

        return true
    }

    public func isLoaded() -> Bool {
        return self.loaded
    }

    private func getWeirdDay(_ date: Date) -> WeirdDay? {
        return weirdDays.first(where: { $0.date.dayCompare(date) == .orderedSame })
    }

    private func date(from string: String) -> Date? {
        if let timedDate = ScheduleContext.dateFormatter.date(from: string) {
            return Calendar.current.startOfDay(for: timedDate)
        }

        return nil
    }

    private func time(from string: String) -> Date? {
        if let datedTime = ScheduleContext.timeFormatter.date(from: string) {
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: datedTime)

            return Calendar.current.date(from: dateComponents)
        }

        return nil
    }
}

struct ScheduleBlock {
    public var scheduleClass: ScheduleClass
    public var startTime: Date
    public var endTime: Date
    public weak var scheduleContext: ScheduleContext?
    public var mod: Int?
}

