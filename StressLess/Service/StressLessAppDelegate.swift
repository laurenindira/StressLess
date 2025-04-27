//
//  StressLessAppDelegate.swift
//  StressLess
//
//  Created by Lauren Indira on 4/22/25.
//

import Foundation
import SwiftUI
import FirebaseCore
import UserNotifications


class StressLessAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}
