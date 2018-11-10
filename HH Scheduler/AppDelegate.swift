//
//  AppDelegate.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/3/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var bgContextRefresher: Timer!
    var dailyNotifTimer: Timer!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("Began running HH-Scheduler! Jeffrey Ryan says hello")

        schedule = PSchedule.defaultLoadFromFile(schedule_file_url)
        scheduleContext = ScheduleContext()

        isFirstStartup = !FileManager.default.fileExists(atPath: first_startup_flag_url.path)

        if !isFirstStartup {
            skipNotificationPermissionEntryPoint()
        }
        else {
            FileManager.default.createFile(atPath: first_startup_flag_url.path, contents: nil, attributes: nil)
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        if bgContextRefresher != nil && bgContextRefresher.isValid {
            bgContextRefresher.invalidate()
        }

        bgContextRefresher = createContextRefresher(interval: 3600) // Once an hour
        dailyNotifTimer = createDailyNotificationScheduler()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

        if bgContextRefresher != nil && bgContextRefresher.isValid {
            bgContextRefresher.invalidate()
        }

        bgContextRefresher = createContextRefresher()
        bgContextRefresher.fire()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        do {
            try schedule.saveToFile(schedule_file_url)
            print("Saved schedule file")
        }
        catch {
            print("Failed to save schedule!")
        }

        NotificationController.current().scheduleNotifications()
    }

    func createContextRefresher(interval: TimeInterval = 120) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            if let context = scheduleContext {
                let oldChecksum = context.checksum()

                guard context.refreshContextURL(schedule_info_web_url) else { return }

                let newChecksum = context.checksum()

                if newChecksum != oldChecksum {
                    NotificationController.current().scheduleNotifications()
                }
            }
        }
    }

    func createDailyNotificationScheduler() -> Timer {
        let dayInterval: TimeInterval = 60 * 60 * 24
        return Timer.scheduledTimer(withTimeInterval: dayInterval, repeats: true) { _ in
            NotificationController.current().scheduleNotifications()
        }
    }

    func skipNotificationPermissionEntryPoint() {
        let loadVCId = "LoadingVC"

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialVC = mainStoryboard.instantiateViewController(withIdentifier: loadVCId)

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialVC
        self.window?.makeKeyAndVisible()
    }
}
