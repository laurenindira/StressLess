//
//  StressLessAppDelegate.swift
//  StressLess
//
//  Created by Lauren Indira on 4/22/25.
//

import Foundation
import SwiftUI
import FirebaseCore


class StressLessAppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
