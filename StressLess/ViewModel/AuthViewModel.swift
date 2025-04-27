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
class AuthViewModel: NSObject, ObservableObject {
    static var shared = AuthViewModel()
    
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
        
        if let savedUserData = UserDefaults.standard.data(forKey: "cachedUser"),
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
    
    func deleteAccount(completion: @escaping (Error?) -> Void) async throws {
        guard let currentUser = auth.currentUser else {
            completion(NSError(domain: "UserNotLoggedIn", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in."]))
            return
        }
        
        guard let localUser = self.user else { return }
    
        self.isLoading = true
        
        currentUser.delete { error in
            if let error = error {
                if (error as NSError).code == AuthErrorCode.requiresRecentLogin.rawValue {
                    print("ERROR: Re-authentication required")
                    if localUser.providerRef == "password" {
                        self.promptEmailReauthentication(currentUser: localUser) { reauthError in
                            if let reauthError = reauthError {
                                self.isLoading = false
                                print("ERROR: Failed to re-authenticate: \(reauthError.localizedDescription)")
                                completion(reauthError)
                            } else {
                                self.clearUserCache()
                                self.user = nil
                                self.isLoading = false
                                completion(nil)
                            }
                        }
                    } else {
                        //TODO: gmail reauth
                    }
                } else {
                    self.isLoading = false
                    print("ERROR: \(error.localizedDescription)")
                    completion(error)
                }
            } else {
                //account deleted
                self.clearUserCache()
                self.user = nil
                self.isLoading = false
                completion(nil)
            }
        }
        
    }
    
    private func promptEmailReauthentication(currentUser: User, completion: @escaping (Error?) -> Void) {
        if currentUser.email.isEmpty {
            completion(NSError(domain: "MissingEmail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Email is missing for re-authentication."]))
            return
        }
        
        let alertController = UIAlertController(
            title: "Re-authenticate Account",
            message: "Please re-enter your password to authenticate your account.",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            completion(NSError(domain: "ReauthenticationCanceled", code: 0, userInfo: [NSLocalizedDescriptionKey: "Re-authentication was cancelled by the user."]))
        }))
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            if let password = alertController.textFields?.first?.text, !password.isEmpty {
                let credential = EmailAuthProvider.credential(withEmail: currentUser.email, password: password)
                Auth.auth().currentUser?.reauthenticate(with: credential) { _, error in
                    completion(error)
                }
            } else {
                completion(NSError(domain: "InvalidPassword", code: 0, userInfo: [NSLocalizedDescriptionKey: "Password is required for re-authentication."]))
            }
        }))
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(alertController, animated: true)
        }
    }
    
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
            print("ERROR: Cannot load user - \(String(describing: errorMessage))")
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

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}
