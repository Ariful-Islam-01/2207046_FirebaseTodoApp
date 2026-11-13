//
//  FirebaseTodoAppApp.swift
//  FirebaseTodoApp
//
//  Created by Ashrafur Rahman Nihad on 12/11/26.
//


import SwiftUI
import FirebaseCore

@main
struct FirebaseTodoAppApp: App {

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
