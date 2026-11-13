//
//  AuthService.swift
//  FirebaseTodoApp
//
//  Created by Ashrafur Rahman Nihad on 12/11/26.
//

import Foundation
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    
    private let auth = Auth.auth()
    
    private init() {}
    
    var currentUser: User? {
        return auth.currentUser
    }
    
    func register(email: String, password: String) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        return result.user
    }
    
    func login(email: String, password: String) async throws -> User {
        let result = try await auth.signIn(withEmail: email, password: password)
        return result.user
    }
    
    func logout() throws {
        try auth.signOut()
    }
    
    func addAuthStateListener(onStateChanged: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        return auth.addStateDidChangeListener { _, user in
            onStateChanged(user)
        }
    }
    
    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        auth.removeStateDidChangeListener(handle)
    }
    
    func readableErrorMessage(from error: Error) -> String {
        let nsError = error as NSError
        if let errorCode = AuthErrorCode(rawValue: nsError.code) {
            switch errorCode {
            case .invalidCredential:
                return "Incorrect email or password. If you don't have an account, please register first."
            case .invalidEmail:
                return "Please enter a valid email address."
            case .emailAlreadyInUse:
                return "This email is already registered. Please log in instead."
            case .wrongPassword:
                return "Incorrect password. Please try again."
            case .userNotFound:
                return "No account found with this email. Please register first."
            case .weakPassword:
                return "Password is too weak. Please use at least 6 characters."
            case .networkError:
                return "Network error. Please check your internet connection."
            case .userDisabled:
                return "This account has been disabled."
            case .tooManyRequests:
                return "Too many attempts. Please try again later."
            case .operationNotAllowed:
                return "Email/Password sign-in is not enabled in Firebase Console."
            default:
                break
            }
        }
        
        // Catch invalid credential errors from Firebase email enumeration protection
        if nsError.code == 17004 || error.localizedDescription.localizedCaseInsensitiveContains("credential") {
            return "Incorrect email or password. If you don't have an account, please register first."
        }
        
        return error.localizedDescription
    }
}

