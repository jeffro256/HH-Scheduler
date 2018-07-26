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

    // @todo: Remove
    var f = DateFormatter()

    private override init() {
        super.init()

        // @todo: Remove
        f.dateFormat = "EEEE, MMMM d -- h:mm aa"
        f.locale = Locale(identifier: "en_US")
        f.timeZone = TimeZone(abbreviation: "CST")

        UNUserNotificationCenter.current().delegate = self
    }

    static func current() -> NotificationController {
        return self.inst
    }

    func requestNotificationPermission(forced: Bool = false) {
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

    func scheduleNotifications(days: Int = 14, minsWarning: Int = 5, context: ScheduleContext = scheduleContext, schedule: PSchedule = schedule) {
        print("Scheduling notifications...")

        if !context.isLoaded() {
            print("Schedule context is not loaded! Cannot schedule notifications.")
        }

        let ncenter = UNUserNotificationCenter.current()
        ncenter.removeAllPendingNotificationRequests()

        var requests: [UNNotificationRequest] = []

        let now = Date()
        guard var day = context.getNextSchoolDay(now, scheduled: true, forceNext: false) else { return }

        for _ in 0..<days {
            let blocks = context.getBlocks(day, from: schedule)

            for (b, block) in blocks.enumerated() {
                if b == 0 { continue }

                let prevBlock = blocks[b-1]
                if block.scheduleClass.classID != schedule.freetimeID() && prevBlock.scheduleClass.classID == schedule.freetimeID() {
                    let triggerTime = Calendar.current.date(byAdding: .minute, value: -minsWarning, to: block.startTime)!
                    let triggerTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: triggerTime)

                    var triggerComponents = Calendar.current.dateComponents([.year, .month, .day], from: day)
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

                    print("Notifications date: \(f.string(from: triggerDatetime))")
                }
            }

            guard let nextDay = context.getNextSchoolDay(day, scheduled: true, forceNext: true) else { break }
            day = nextDay
        }

        for request in requests {
            ncenter.add(request) { (error) in
                if error != nil {
                    print(error.debugDescription)
                }
            }
        }

        print("done scheduleing")
    }

    func filterDeliveredNotifications() {
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

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("#####################################")
        print(response.notification.request.identifier)
        print(response.notification.date)
        print(response.actionIdentifier)
        print(response.notification.request.content.userInfo)
        print("#####################################")
    }
}
