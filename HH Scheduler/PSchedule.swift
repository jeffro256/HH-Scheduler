//
//  Schedule.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 7/11/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

class PSchedule: NSObject, NSCoding, NSCopying, PersonalSchedule {
    public static let defaultNumDays = 6
    public static let defaultNumMods = 18

    private var numDays: Int
    private var numMods: Int
    private var classes: [ScheduleClass]
    private var schedule: [[PersonalSchedule.ClassID]]

    override var description: String {
        var res = "Classes:\n"

        for classInfo in classes {
            res += "\(classInfo.name), id: \(classInfo.classID), color: \(classInfo.color)\n"
        }

        res += "Schedule:\n"

        for day in schedule {
            for id in day {
                res += "\(id) "
            }

            res += "\n"
        }

        return res
    }

    init(days: Int = PSchedule.defaultNumDays, mods: Int = PSchedule.defaultNumMods) {
        let freetimeColor = UIColor(0xEFEFF4)
        let freetimeClass = ScheduleClass(classID: 0, classIndex: 0, name: "Free Time", color: freetimeColor)

        self.numDays = days
        self.numMods = mods
        self.classes = [freetimeClass]
        self.schedule = [[PersonalSchedule.ClassID]](repeating: [PersonalSchedule.ClassID](repeating: 0, count: mods), count: days)

        super.init()
    }

    init(numDays: Int, numMods: Int, classes: [ScheduleClass], schedule: [[PersonalSchedule.ClassID]]) {
        self.numDays = numDays
        self.numMods = numMods
        self.classes = classes
        self.schedule = schedule

        super.init()
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = PSchedule(numDays: self.numDays, numMods: self.numMods, classes: self.classes, schedule: self.schedule)
        return copy
    }

    static func loadFromFile(_ target: URL) -> PSchedule? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: target.path) as? PSchedule
    }

    static func defaultLoadFromFile(_ target: URL) -> PSchedule {
        let result = loadFromFile(target) ?? PSchedule()

        return result
    }

    func saveToFile(_ target: URL) throws {
        if !NSKeyedArchiver.archiveRootObject(self, toFile: target.path) {
            throw NSError(domain: "Failed to save schedule to file", code: 2, userInfo: nil)
        }
    }

    required convenience init(coder aDecoder: NSCoder) {
        let numDays = aDecoder.decodeInteger(forKey: "numDays")
        let numMods = aDecoder.decodeInteger(forKey: "numMods")
        let ids = aDecoder.decodeObject(forKey: "ids") as? [PersonalSchedule.ClassID]
        let names = aDecoder.decodeObject(forKey: "names") as? [String]
        let colors = aDecoder.decodeObject(forKey: "colors") as? [UIColor]
        let schedule = aDecoder.decodeObject(forKey: "schedule") as? [[Int]]

        if let ids = ids, let names = names, let colors = colors, let schedule = schedule {
            var classes = [ScheduleClass]()

            for i in 0..<ids.count {
                classes.append(ScheduleClass(classID: ids[i], classIndex: i, name: names[i], color: colors[i]))
            }

            self.init(numDays: numDays, numMods: numMods, classes: classes, schedule: schedule)
        }
        else {
            self.init()

            print("Failed to initalize schedule with coder! Defaulting to empty schedule.")
        }
    }

    func encode(with aCoder: NSCoder) {
        let ids = classes.map({ $0.classID })
        let names = classes.map({ $0.name })
        let colors = classes.map({ $0.color })

        aCoder.encode(self.numDays, forKey: "numDays")
        aCoder.encode(self.numMods, forKey: "numMods")
        aCoder.encode(ids, forKey: "ids")
        aCoder.encode(names, forKey: "names")
        aCoder.encode(colors, forKey: "colors")
        aCoder.encode(self.schedule, forKey: "schedule")
    }

    // Personal Schedule Interface

    func getNumDays() -> Int {
        return numDays
    }

    func getNumMods() -> Int {
        return numMods
    }

    func getNumClasses() -> Int {
        return classes.count
    }

    func getClassID(index: Int) -> PersonalSchedule.ClassID {
        return classes[index].classID
    }

    func getClassInfo(withID id: PersonalSchedule.ClassID) -> ScheduleClass? {
        return classes.first(where: { c in c.classID == id })
    }

    func setClassName(withID id: PersonalSchedule.ClassID, to name: String) {
        guard let classIndex = classes.index(where: { c in c.classID == id}) else { return }
        classes[classIndex].name = name
    }

    func setClassColor(withID id: PersonalSchedule.ClassID, to color: UIColor) {
        guard let classIndex = classes.index(where: { c in c.classID == id}) else { return }
        classes[classIndex].color = color
    }

    func setClassIndex(withID id: PersonalSchedule.ClassID, to index: Int) {
        guard !classes.isEmpty else { return }
        guard let oldIndex = classes.index(where: { c in c.classID == id}) else { return }
        let newIndex = (index < 0) ? 0 : ((index >= classes.count) ? (classes.count - 1) : index)

        classes.insert(classes.remove(at: oldIndex), at: newIndex)

        for i in min(oldIndex, newIndex)..<classes.count {
            classes[i].classIndex = i
        }
    }

    @discardableResult
    func addClass(withName name: String, color: UIColor) -> PersonalSchedule.ClassID {
        let id = generateID()
        let newClass = ScheduleClass(classID: id, classIndex: classes.count, name: name, color: color)

        classes.append(newClass)

        return id
    }

    func removeClass(withID id: PersonalSchedule.ClassID) {
        guard id != self.freetimeID() else { return }

        if let removeIndex = classes.index(where: { c in c.classID == id }) {
            classes.remove(at: removeIndex)

            for i in removeIndex..<classes.count {
                classes[i].classIndex = i
            }
        }
    }

    func getClassID(atDay day: Int, mod: Int) -> PersonalSchedule.ClassID {
        return schedule[day][mod]
    }

    func setClassID(atDay day: Int, mod: Int, to id: PersonalSchedule.ClassID) {
        guard classes.contains(where: { c in c.classID == id }) else { return }
        self.schedule[day][mod] = id
    }

    func getClassInfo(atDay day: Int, mod: Int) -> ScheduleClass {
        return self.getClassInfo(withID: self.getClassID(atDay: day, mod: mod))!
    }

    func freetimeID() -> PersonalSchedule.ClassID {
        return 0
    }

    // Done with Personal Schedule Interface

    private func generateID() -> PersonalSchedule.ClassID {
        var id: PersonalSchedule.ClassID = 0

        while classes.contains(where: { c in c.classID == id }) {
            id += 1
        }

        return id
    }
}
