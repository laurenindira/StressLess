//
//  SettingsView.swift
//  StressLess
//
//  Created by Lauren Indira on 4/27/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var healthKitManager: HealthKitViewModel
    
    @State var notificationsOn: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var showDeleteAccountConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                //HEADER
                Text("Settings")
                    .font(.system(size: 35))
                    .bold()
                
                //NOTIFICATIONS
                VStack(alignment: .leading) {
                    Text("Notifications")
                        .font(.system(size: 25))
                        .bold()
                    Toggle("Disable Notifications", isOn: $notificationsOn)
                }
                
                Divider()
                
                //HEALTH DATA
                VStack(alignment: .leading, spacing: 20) {
                    Text("Health Data")
                        .font(.system(size: 25))
                        .bold()
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Text("Delete my data")
                            .foregroundStyle(Color.stressred)
                    }
                }
                
                Divider()
                
                //ACCOUNT MANAGEMENT
                VStack(alignment: .leading, spacing: 20) {
                    Text("Account Management")
                        .font(.system(size: 25))
                        .bold()
                    Button("Log out") {
                        Task { await auth.signOut() }
                    }
                    
                    Button {
                        showDeleteAccountConfirmation = true
                    } label: {
                        Text("Delete my account")
                            .foregroundStyle(Color.stressred)
                    }
                }
                
                Spacer()
            }
            .padding()
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(title: Text("Are you sure?"), message: Text("This action will permanently delete all data associated with this account"), primaryButton: .destructive(Text("Delete")) { Task { await healthKitManager.deleteUserData(for: auth.user?.id ?? "" )} }, secondaryButton: .cancel())
            }
        }
        
        .alert(isPresented: $showDeleteAccountConfirmation) {
            Alert(title: Text("Are you sure?"), message: Text("This action will permanently delete your account and all associated data"),
                  primaryButton: .destructive(Text("Delete")) {
                Task {
                    do {
                        try await auth.deleteAccount() { error in
                            if let error = error {
                                print("ERROR: Something went wrong deleting account")
                            } else {
                                print("SUCCESS: Account deleted")
                            }
                        }
                    } catch {
                        print("ERROR: Failed to delete account")
                    }
                }
                
            },
                  secondaryButton: .cancel())
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
        .environmentObject(HealthKitViewModel())
}
