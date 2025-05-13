//
//  EditProfileView.swift
//  StressLess
//
//  Created by Lauren Indira on 4/27/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var healthKitManager: HealthKitViewModel
    
    @Binding var isEditing: Bool
    
    @State var displayName: String = ""
    @State var selectedGoals: [String] = []
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    let goals = ["Reduce my stress during work/study sessions over time", "Reduce the amount of acute stress experienced during a session", "Track my stress levels over time"]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Edit Profile")
                    .font(.system(size: 25))
                    .bold()
                    .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("New Display Name")
                            .font(.headline)
                        GenTextField(placeholder: "display name", text: $displayName)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Change Goals")
                            .font(.headline)
                        ForEach(goals, id: \.self) { goal in
                            Text(goal)
                                .foregroundStyle(selectedGoals.contains(goal) ? Color.lod : Color.dol)
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selectedGoals.contains(goal) ? Color.prim : Color.surface)
                                }
                                .onTapGesture {
                                    if selectedGoals.contains(goal) {
                                        selectedGoals.removeAll(where: { $0 == goal })
                                    } else {
                                        selectedGoals.insert(goal, at: 0)
                                    }
                                }
                        }
                    }
                }
                .padding(.bottom, 20)
                
                Button {
                    guard let currentUser = auth.user else { return }
                    Task {
                        try await auth.updateUserData(user: User(id: currentUser.id, displayName: displayName, email: currentUser.email, profilePicture: currentUser.profilePicture, providerRef: currentUser.providerRef, creationDate: currentUser.creationDate, dataSource: currentUser.dataSource, goals: selectedGoals, totalSessions: currentUser.totalSessions, averageHeartRate: currentUser.averageHeartRate, averageHRV: currentUser.averageHRV, lastSession: currentUser.lastSession ))
                    }
                    isEditing.toggle()
                } label: {
                    GenButton(text: "Save Changes", backgroundColor: Color.stressgreen, textColor: Color.lod, isSystemImage: false)
                }
            }
            .padding()
            .onAppear {
                displayName = auth.user?.displayName ?? ""
                selectedGoals = auth.user?.goals ?? []
            }
        }
    }
}

#Preview {
    EditProfileView(isEditing: .constant(true))
        .environmentObject(AuthViewModel())
        .environmentObject(HealthKitViewModel())
}
