//
//  AuthViewModel.swift
//  FirebaseTodoApp
//
//  Created by Ashrafur Rahman Nihad on 12/11/26.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    var currentUserId: String? {
        userSession?.uid
    }
    
    private let authService = AuthService.shared
    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        self.userSession = authService.currentUser
        self.authListenerHandle = authService.addAuthStateListener { [weak self] user in
            Task { @MainActor in
                self?.userSession = user
            }
        }
    }
    
    deinit {
        if let handle = authListenerHandle {
            authService.removeAuthStateListener(handle)
        }
    }
    
    func login(email: String, password: String) async -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please enter both email and password."
            return false
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let user = try await authService.login(email: trimmedEmail, password: password)
            self.userSession = user
            self.isLoading = false
            return true
        } catch {
            self.isLoading = false
            self.errorMessage = authService.readableErrorMessage(from: error)
            return false
        }
    }
    
    func register(email: String, password: String) async -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please enter both email and password."
            return false
        }
        
        guard password.count >= 6 else {
            self.errorMessage = "Password must be at least 6 characters long."
            return false
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let user = try await authService.register(email: trimmedEmail, password: password)
            self.userSession = user
            self.isLoading = false
            return true
        } catch {
            self.isLoading = false
            self.errorMessage = authService.readableErrorMessage(from: error)
            return false
        }
    }
    
    func logout() {
        do {
            try authService.logout()
            self.userSession = nil
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func clearError() {
        self.errorMessage = nil
    }
}
