//
//  Session.swift
//  StressLess
//
//  Created by Lauren Indira on 4/27/25.
//

import Foundation

struct Session: Identifiable, Codable {
    var id: String
    var userID: String
    var sessionDate: Date
    var sessionLength: Double
    var stressEvents: Int
    var minHeartRate: Double
    var maxHeartRate: Double
}
