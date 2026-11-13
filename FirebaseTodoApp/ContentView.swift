//
//  ContentView.swift
//  FirebaseTodoApp
//
//  Created by Ashrafur Rahman Nihad on 12/11/26.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if let user = authViewModel.userSession {
                TodoListView(userId: user.uid)
                    .id(user.uid)
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
