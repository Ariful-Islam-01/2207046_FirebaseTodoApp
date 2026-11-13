//
//  LoginView.swift
//  FirebaseTodoApp
//
//  Created by Ashrafur Rahman Nihad on 12/11/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    
                    Text("Firebase Todo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Sign in to continue")
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
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Error message
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Login Button
                Button {
                    Task {
                        _ = await authViewModel.login(email: email, password: password)
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
                        Text("Log In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                .padding(.horizontal)
                
                Spacer()
                
                // Navigation to Register
                NavigationLink {
                    RegisterView()
                } label: {
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        Text("Register")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .font(.footnote)
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .onAppear {
                authViewModel.clearError()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}

