//
//  UserViewModel.swift
//  StressLess
//
//  Created by Lauren Indira on 4/22/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

@Observable
class UserViewModel: NSObject, ObservableObject {
    static var shared = UserViewModel()
    
    var user: User? {
        didSet {
            if let currentUser = user {
                saveUserToCache(currentUser)
                UserDefaults.standard.set(currentUser != nil, forKey: "isSignedIn")
            } else {
                clearUserCache()
            }
        }
    }
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    private var userKey = "cachedUser"
    
    var isLoading: Bool = false
    var errorMessage: String?
    
    override init() {
        super.init()
        
        guard auth.currentUser != nil else {
            self.user = nil
            return
        }
        
        if let savedUserData = UserDefaults.standard.data(forKey: userKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedUserData) {
            self.user = savedUser
            UserDefaults.standard.set(true, forKey: "isSignedIn")
        }
    }
    
    //MARK: - Account creation
    func signUpWithEmail(newUser: User, email: String, password: String) async throws {
        self.isLoading = true
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let user = User(id: result.user.uid, displayName: newUser.displayName, email: email, providerRef: "email/password", creationDate: newUser.creationDate, goals: newUser.goals, totalSessions: 0, averageHeartRate: newUser.averageHeartRate, averageHRV: newUser.averageHRV)
            self.user = user
            try await saveUserToFirestore(user: user)
            saveUserToCache(user)
            UserDefaults.standard.set(true, forKey: "isSignedIn")
            self.isLoading = false
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Sign up failure - \(String(describing: errorMessage))")
            throw error
        }
    }
    
    private func saveUserToFirestore(user: User) async throws {
        do {
            try await db.collection("users").document(user.id).setData([
                "id": user.id,
                "displayName": user.displayName,
                "email": user.email,
                "profilePicture": user.profilePicture ?? "",
                "providerRef": user.providerRef,
                "creationDate": user.creationDate,
                "dataSource": user.dataSource ?? "unknown",
                "goals": user.goals,
                "totalSessions": user.totalSessions,
                "averageHeartRate": user.averageHeartRate,
                "averageHRV": user.averageHRV
            ])
            print("SUCCESS: Saved user to Firestore")
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to save to Firestore - \(String(describing: errorMessage))")
            throw error
        }
    }
    
    //MARK: - Sign in
    
    //MARK: - Sign out + deletion
    func signOut() async {
        guard auth.currentUser != nil else { return }
        self.isLoading = true
        
        do {
            clearUserCache()
            try auth.signOut()
            self.user = nil
        } catch let error as NSError {
            self.errorMessage = String(describing: error.localizedDescription)
            print("ERROR: Sign out error - \(String(describing: errorMessage))")
        }
    }
    //TODO: FIX
    
//    func deleteAccount() async {
//        guard let user = auth.currentUser else { return }
//        var credential: AuthCredential
//        
//        self.isLoading = true
//        
//        user.delete { error in
//            if let error = error {
//                self.isLoading = false
//                
//                if (error as NSError).code == AuthErrorCode.requiresRecentLogin.rawValue {
//                    print("ERROR: Re-authentication required")
//                    self.promptReauthentication() { reauthError in
//                        if let reauthError = reauthError {
//                            print("ERROR: Failed to re-authenticate")
//                            return
//                        } else {
//                            self.user = nil
//                            clearUserCache()
//                        }
//                    }
//                    
//                } else {
//                    print("ERROR: \(error.localizedDescription)")
//                    return
//                }
//            } else {
//                
//                print("SUCCESS: Account deleted")
//            }
//        }
//    }
//    
//    private func promptReauthentication() {
//        
//    }
    
    //TODO: this is untested, make sure it works later on
//    func deleteUserAccount(completion: @escaping (Error?) -> Void) async throws {
//        guard let user = auth.currentUser else {
//            completion(NSError(domain: "UserNotLoggedIn", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in"]))
//            return
//        }
//        
//        isLoading = true
//        
//        let userID = user.uid
//        let userRef = db.collection("users").document(userID)
//        
//        do {
//            try await userRef.delete()
//            print("SUCCESS: User removed from collection")
//            
//            user.delete { error in
//                if let error = error {
//                    self.isLoading = false
//                    if (error as NSError) == AuthErrorCode.requiresRecentLogin.rawValue {
//                        print("ERROR: Re-authentication required")
//                        self.promptReauthentication() { reauthError in
//                            if let reauthError = reauthError {
//                                print("ERROR: Failed to re-authenticate user: \(reauthError.localizedDescription)")
//                                completion(reauthError)
//                            } else {
//                                self.user = nil
//                                UserDefaults.standard.set(false, forKey: "isSignedIn")
//                                clearUserCache()
//                                completion(nil)
//                            }
//                        }
//                    } else let error as NSError {
//                        self.errorMessage = String(describing: error.localizedDescription)
//                        print("ERROR: Failed to delete account - \(errorMessage)")
//                        completion(error)
//                    }
//                }
//            } else {
//                self.user = nil
//                UserDefaults.standard.set(false, forKey: "isSignedIn")
//                completion(nil)
//            }
//        } catch let error as NSError {
//            self.isLoading = false
//            self.errorMessage = String(describing: error.localizedDescription)
//            print("ERROR: Failed to delete account - \(errorMessage)")
//            completion(error)
//        }
//    }
    
    //MARK: - Loading User
    private func loadSession() async {
        guard auth.currentUser != nil else {
            self.user = nil
            return
        }
        
        if let cachedUser = loadUserFromCache() {
            self.user = cachedUser
        } else {
            await loadUserFromFirebase()
        }
        UserDefaults.standard.set(true, forKey: "isSignedIn")
    }
    
    func loadUserFromFirebase() async {
        guard let currentUser = auth.currentUser else { return }
        do {
            let snapshot = try await db.collection("users").document(currentUser.uid).getDocument()
            if let userData = snapshot.data() {
                let currentUser = try Firestore.Decoder().decode(User.self, from: userData)
                self.user = currentUser
                saveUserToCache(currentUser)
                print("CURRENT USER: \(String(describing: self.user))")
            }
        } catch let error as NSError {
            self.errorMessage = String(describing: error.localizedDescription)
            print("ERROR: Cannot load user - \(errorMessage)")
        }
    }
    
    private func loadUserFromCache() -> User? {
        guard let savedUserData = UserDefaults.standard.data(forKey: userKey) else { return nil }
        print("SUCCESS: Cached user loaded")
        return try? JSONDecoder().decode(User.self, from: savedUserData)
    }
    
    //MARK: - Local caching
    private func saveUserToCache(_ user: User) {
        if let encodedUser = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedUser, forKey: userKey)
        }
        print("SUCCESS: Saved user to cache")
    }
    
    private func updateCachedUser(user: User) {
        if let encodedUser = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedUser, forKey: userKey)
        }
        print("SUCCESS: User updated in cache")
    }
    
    private func clearUserCache() {
        UserDefaults.standard.removeObject(forKey: userKey)
        UserDefaults.standard.set(false, forKey: "isSignedIn")
    }
}
