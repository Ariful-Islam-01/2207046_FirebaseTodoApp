//
//  RegisterView.swift
//  FirebaseTodoApp
//
//  Created by Ashrafur Rahman Nihad on 12/11/26.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var localErrorMessage: String?
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Header
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
                
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Sign up to start organizing tasks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 12)
            
            // Input Fields
            VStack(spacing: 14) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                SecureField("Password (min 6 characters)", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Error Message
            if let error = localErrorMessage ?? authViewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Register Button
            Button {
                localErrorMessage = nil
                guard password == confirmPassword else {
                    localErrorMessage = "Passwords do not match."
                    return
                }
                
                Task {
                    _ = await authViewModel.register(email: email, password: password)
                }
            } label: {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                } else {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .disabled(
                authViewModel.isLoading ||
                email.isEmpty ||
                password.isEmpty ||
                confirmPassword.isEmpty
            )
            .padding(.horizontal)
            
            Spacer()
            
            // Back to Login Link
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .foregroundColor(.secondary)
                    Text("Log In")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .font(.footnote)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            authViewModel.clearError()
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}

