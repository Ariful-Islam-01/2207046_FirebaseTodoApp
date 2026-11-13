//
//  TaskViewModel.swift
//  FirebaseTodoApp
//
//  Created by Ashrafur Rahman Nihad on 12/11/26.
//

import Foundation
import Combine

@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let firestoreService = FirestoreService.shared
    let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    /// Fetches all tasks for the authenticated user and refreshes the list
    func fetchTasks() async {
        guard !userId.isEmpty else { return }
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            self.tasks = try await firestoreService.fetchTasks(for: userId)
        } catch {
            self.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
        }
        self.isLoading = false
    }
    
    /// Creates a new task and refreshes the task list
    func addTask(title: String, description: String) async -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            self.errorMessage = "Task title cannot be empty."
            return false
        }
        
        let newTask = TaskModel(
            title: trimmedTitle,
            description: trimmedDescription,
            isCompleted: false,
            createdAt: Date(),
            userId: userId
        )
        
        do {
            try firestoreService.addTask(newTask)
            await fetchTasks()
            return true
        } catch {
            self.errorMessage = "Failed to add task: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Updates an existing task's title and description and refreshes the task list
    func updateTask(task: TaskModel, newTitle: String, newDescription: String) async -> Bool {
        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = newDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            self.errorMessage = "Task title cannot be empty."
            return false
        }
        
        var updatedTask = task
        updatedTask.title = trimmedTitle
        updatedTask.description = trimmedDescription
        
        do {
            try firestoreService.updateTask(updatedTask)
            await fetchTasks()
            return true
        } catch {
            self.errorMessage = "Failed to update task: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Toggles the completion status of a task and refreshes the task list
    func toggleTaskCompletion(_ task: TaskModel) async {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        
        // Optimistic local update
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = updatedTask
        }
        
        do {
            try firestoreService.updateTask(updatedTask)
            await fetchTasks()
        } catch {
            self.errorMessage = "Failed to update task status: \(error.localizedDescription)"
            await fetchTasks()
        }
    }
    
    /// Deletes a task and refreshes the task list
    func deleteTask(_ task: TaskModel) async {
        guard let taskId = task.id else { return }
        
        // Optimistic local removal
        tasks.removeAll { $0.id == taskId }
        
        do {
            try await firestoreService.deleteTask(id: taskId)
            await fetchTasks()
        } catch {
            self.errorMessage = "Failed to delete task: \(error.localizedDescription)"
            await fetchTasks()
        }
    }
}
