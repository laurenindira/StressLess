//
//  User.swift
//  StressLess
//
//  Created by Lauren Indira on 4/22/25.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var displayName: String
    var email: String
    var profilePicture: String?
    var providerRef: String
    var creationDate: Date
    
    //ONBOARDING
    var dataSource: String?
    var goals: [String]
    
    //TRACKING
    var totalSessions: Int
    var averageHeartRate: Int
    var averageHRV: Int
    var lastSession: Date?
}
