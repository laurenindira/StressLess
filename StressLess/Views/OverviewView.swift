//
//  OverviewView.swift
//  StressLess
//
//  Created by Raihana Zahra on 4/27/25.
//

import SwiftUI

struct OverviewView: View {
    @StateObject private var heartRateVM = HeartRateViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            
            HeartRateCard(bpm: heartRateVM.bpm)
            HRVCard(hrv: heartRateVM.hrv)
        }
        .padding()
    }
}

#Preview {
    OverviewView()
}
