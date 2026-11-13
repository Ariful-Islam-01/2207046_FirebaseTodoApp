//
//  TaskModel.swift
//  FirebaseTodoApp
//
//  Created by Ashrafur Rahman Nihad on 12/11/26.
//

import Foundation
import FirebaseFirestore

struct TaskModel: Identifiable, Codable {
    @DocumentID var id: String?

    var title: String
    var description: String
    var isCompleted: Bool
    var createdAt: Date
    var userId: String

    init(
        id: String? = nil,
        title: String,
        description: String,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        userId: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.userId = userId
    }
}
