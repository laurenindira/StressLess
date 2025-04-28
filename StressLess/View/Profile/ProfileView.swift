//
//  ProfileView.swift
//  StressLess
//
//  Created by Lauren Indira on 4/27/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var sessionManager: HealthKitViewModel
    
    @State var isEditing: Bool = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                //HEADER
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hey \(auth.user?.displayName ?? "friend"),")
                        .bold()
                        .font(.system(size: 35))
                    Text("Welcome to your profile!")
                        .font(.title2)
                        .font(.system(size: 40))
                        .padding(.bottom, 20)
                    
                    HStack {
                        Spacer()
                        Button {
                            isEditing.toggle()
                        } label: {
                            Text("Edit my info")
                                .font(.title3).bold()
                                .padding()
                                .foregroundStyle(Color.lod)
                                .background {
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.prim)
                                }
                        }
                    }
                }
                //GOAL
                VStack(alignment: .leading) {
                    Text("My Goals")
                        .font(.title2)
                        .bold()
                    Text(auth.user?.goals.joined(separator: ", ") ?? "No goals set")
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.prim.opacity(0.25), radius: 3, y: 2)
                }
                
                //PERSONAL INFORMATION
                VStack(alignment: .leading, spacing: 12) {
                    Text("Personal Information")
                        .font(.title2)
                        .bold()
                    ProfileRow(title: "Name", content: auth.user?.displayName ?? "unknown")
                    ProfileRow(title: "Email", content: auth.user?.email ?? "unknown")
                    ProfileRow(title: "Number of sessions", content: String(describing: auth.user?.totalSessions ?? 0))
                    ProfileRow(title: "Average Heart Rate", content: String(describing: auth.user?.averageHeartRate ?? 0))
                    ProfileRow(title: "Average HRV", content: String(describing: auth.user?.averageHRV ?? 0))
                    ProfileRow(title: "Data Source", content: auth.user?.dataSource ?? "unknown")
                    ProfileRow(title: "Stressed Less since", content: dateFormatter.string(from:  auth.user?.creationDate ?? Date()) )
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.prim.opacity(0.25), radius: 3, y: 2)
                }
                
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gear")
                                .font(.title3)
                                .foregroundStyle(Color.dol)
                        }
                        
                        Button {
                            isEditing.toggle()
                        } label: {
                            Image(systemName: "pencil")
                                .font(.title3)
                                .foregroundStyle(Color.dol)
                        }
                    }
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.back
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $isEditing) {
                EditProfileView(isEditing: $isEditing)
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(HealthKitViewModel())
}


struct ProfileRow: View {
    var title: String
    var content: String
    
    var body: some View {
        HStack {
            Text(title)
                .bold()
            Spacer()
            Text(content)
        }
    }
}
