//
//  FirestoreService.swift
//  FirebaseTodoApp
//
//  Created by Ashrafur Rahman Nihad on 12/11/26.
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    
    private let db = Firestore.firestore()
    private let collectionName = "tasks"
    
    private init() {}
    
    /// Fetches all tasks for a specific user, sorted newest first
    func fetchTasks(for userId: String) async throws -> [TaskModel] {
        let snapshot = try await db.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        let tasks = snapshot.documents.compactMap { document in
            try? document.data(as: TaskModel.self)
        }
        
        return tasks.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// Adds a new task. Note: addDocument(from:) is synchronous throwing.
    func addTask(_ task: TaskModel) throws {
        _ = try db.collection(collectionName).addDocument(from: task)
    }
    
    /// Updates an existing task. Note: setData(from:) is synchronous throwing.
    func updateTask(_ task: TaskModel) throws {
        guard let id = task.id else {
            throw NSError(
                domain: "FirestoreService",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Task ID is missing."]
            )
        }
        try db.collection(collectionName).document(id).setData(from: task)
    }
    
    /// Deletes a task by document ID.
    func deleteTask(id: String) async throws {
        try await db.collection(collectionName).document(id).delete()
    }
}

