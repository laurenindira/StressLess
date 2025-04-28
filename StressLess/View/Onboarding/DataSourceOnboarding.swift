////
////  DataSourceOnboarding.swift
////  StressLess
////
////  Created by Lauren Indira on 4/26/25.
////
//
//import SwiftUI
//
//struct DataSourceOnboarding: View {
//    @Binding var user: User
//    @Binding var step: Int
//    
//    var body: some View {
//        VStack {
//            Button {
//                step += 1
//            } label: {
//                GenButton(text: "Next", backgroundColor: Color.prim, textColor: Color.lod, isSystemImage: true,  imageRight: "arrow.right")
//            }
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    DataSourceOnboarding(user: .constant(User(id: "", displayName: "", email: "", providerRef: "", creationDate: Date(), goals: [], totalSessions: 0, averageHeartRate: 0, averageHRV: 0)), step: .constant(2))
//}
