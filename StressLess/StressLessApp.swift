//
//  StressLessApp.swift
//  StressLess
//
//  Created by Lauren Indira on 4/22/25.
//

import SwiftUI

@main
struct StressLessApp: App {
    @UIApplicationDelegateAdaptor(StressLessAppDelegate.self) var appDelegate
    @AppStorage("isSignedIn") var isSignedIn = false
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
