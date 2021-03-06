//
//  NotificationController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 7/20/18.
//  Copyright © 2018 Jeffrey Ryan. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationController: NSObject, UNUserNotificationCenterDelegate {
    private static let inst = NotificationController()

    private let serialQueue = DispatchQueue(label: "com.jeffaryan.HHPSNotif")

    // @todo: Remove
    private var f = DateFormatter()

    private override init() {
        super.init()

        // @todo: Remove
        f.dateFormat = "EEEE, MMMM d -- h:mm aa"
        f.locale = Locale(identifier: "en_US")
        f.timeZone = TimeZone(abbreviation: "CST")

        UNUserNotificationCenter.current().delegate = self
    }

    public static func current() -> NotificationController {
        return self.inst
    }

    public func requestNotificationPermission(forced: Bool = false) {
        let ncenter = UNUserNotificationCenter.current()

        let authorizationOptions: UNAuthorizationOptions = [.alert, .sound]

        ncenter.getNotificationSettings { (settings) in
            if forced || settings.authorizationStatus == .notDetermined {
                ncenter.requestAuthorization(options: authorizationOptions) { (granted, error) in
                    if error != nil {
                        print(error.debugDescription)
                    }
                }
            }
        }
    }

    public func scheduleNotifications(minsWarning: Int = 5, context: ScheduleContext = scheduleContext, schedule: PSchedule = schedule) {
        print("Scheduling notifications...")

        let startT = Date()

        self.serialQueue.async {
            self._scheduleNotifications(minsWarning: minsWarning, context: context, schedule: schedule)

            let endT = Date()
            let elapsed = endT.timeIntervalSinceReferenceDate - startT.timeIntervalSinceReferenceDate
            print("Scheduling time: \(elapsed)s.")
        }
    }

    public func filterDeliveredNotifications() {
        let ncenter = UNUserNotificationCenter.current()

        ncenter.getDeliveredNotifications { (notifications) in
            let now = Date()
            var removeIDs: [String] = []

            for notification in notifications {
                if notification.date.dayCompare(now) == .orderedAscending {
                    removeIDs.append(notification.request.identifier)
                }
            }

            ncenter.removeDeliveredNotifications(withIdentifiers: removeIDs)
        }
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("#####################################")
        print(response.notification.request.identifier)
        print(response.notification.date)
        print(response.actionIdentifier)
        print(response.notification.request.content.userInfo)
        print("#####################################")
    }

    private func _scheduleNotifications(minsWarning: Int = 5, context: ScheduleContext = scheduleContext, schedule: PSchedule = schedule) {
        let maxNotifications = 60

        if !context.isLoaded() {
            print("Schedule context is not loaded! Cannot schedule notifications.")
        }

        let ncenter = UNUserNotificationCenter.current()
        ncenter.removeAllPendingNotificationRequests()

        var requests: [UNNotificationRequest] = []

        let now = Date()
        var day = context.getNextSchoolDay(now, scheduled: true, forceNext: false)
        var lastCycle = -1

        var numNotifications = 0
        scheduleLoop: while day != nil {
            let explLandmark = (lastCycle > 0) ? (day!, lastCycle) : nil
            let block_data = context.getBlocks(day!, from: schedule, explicitLandmark: explLandmark)
            lastCycle = block_data.0
            let blocks = block_data.1

            for (b, block) in blocks.enumerated() {
                if b == 0 { continue }

                let prevBlock = blocks[b-1]
                if block.scheduleClass.classID != schedule.freetimeID() && prevBlock.scheduleClass.classID == schedule.freetimeID() {
                    let triggerTime = Calendar.current.date(byAdding: .minute, value: -minsWarning, to: block.startTime)!
                    let triggerTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: triggerTime)

                    var triggerComponents = Calendar.current.dateComponents([.year, .month, .day], from: day!)
                    triggerComponents.hour = triggerTimeComponents.hour
                    triggerComponents.minute = triggerTimeComponents.minute

                    let triggerDatetime = Calendar.current.date(from: triggerComponents)!
                    if Calendar.current.compare(triggerDatetime, to: now, toGranularity: .minute) == .orderedAscending {
                        continue
                    }

                    let reqIdentifier = UUID().uuidString

                    let reqContent = UNMutableNotificationContent()
                    let className = block.scheduleClass.name
                    reqContent.title = "Time For Class"
                    reqContent.body = "'\(className)' starts in \(minsWarning) minutes!"
                    reqContent.sound = UNNotificationSound.default()

                    let reqTrigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

                    let request = UNNotificationRequest(identifier: reqIdentifier, content: reqContent, trigger: reqTrigger)

                    requests.append(request)

                    print("\(className): \(f.string(from: triggerDatetime))")

                    numNotifications += 1
                    if numNotifications >= maxNotifications {
                        break scheduleLoop
                    }
                }
            }

            day = context.getNextSchoolDay(day!, scheduled: true, forceNext: true)
        }

        for request in requests {
            ncenter.add(request) { (error) in
                if error != nil {
                    print(error.debugDescription)
                }
            }
        }
    }
}
