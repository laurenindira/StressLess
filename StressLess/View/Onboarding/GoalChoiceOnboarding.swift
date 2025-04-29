//
//  GoalChoiceOnboarding.swift
//  StressLess
//
//  Created by Lauren Indira on 4/27/25.
//

import SwiftUI

struct GoalChoiceOnboarding: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var healthKitManager: HealthKitViewModel
    
    @Binding var user: User
    @Binding var step: Int
    
    let goals = ["Manage acute stress during work periods", "Reduce the number of stress events experienced", "Track stress levels over time"]
    
    var selectedGoals: [String] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Alright! Now choose a goal")
                .font(.headline)
            
            VStack (spacing: 10) {
                ForEach(goals, id: \.self) { goal in
                    Text(goal)
                        .foregroundStyle(user.goals.contains(goal) ? Color.lod : Color.dol)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(user.goals.contains(goal) ? Color.prim : Color.surface)
                        }
                        .onTapGesture {
                            if user.goals.contains(goal) {
                                user.goals.removeAll(where: { $0 == goal })
                            } else {
                                user.goals.insert(goal, at: 0)
                            }
                        }
                }
            }
            
            
            Button {
                if !user.goals.isEmpty { step += 1 }
            } label: {
                GenButton(text: "Next", backgroundColor: Color.prim, textColor: Color.lod, isSystemImage: true,  imageRight: "arrow.right")
            }
            .disabled(user.goals.isEmpty)
            .opacity(user.goals.isEmpty ? 0.5 : 1)
            .padding(.top, 20)
            
        }
        .padding()
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button() {
                    step -= 1
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.body)
                        Text("Back")
                    }
                    .foregroundStyle(Color.prim)
                }
            }
        }
    }
}

#Preview {
    GoalChoiceOnboarding(user: .constant(User(id: "", displayName: "", email: "", providerRef: "", creationDate: Date(), goals: [], totalSessions: 0, averageHeartRate: 0, averageHRV: 0)), step: .constant(1))
        .environmentObject(AuthViewModel())
        .environmentObject(HealthKitViewModel())
}
