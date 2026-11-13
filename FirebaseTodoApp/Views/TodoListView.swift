//
//  TodoListView.swift
//  FirebaseTodoApp
//
//  Created by Ashrafur Rahman Nihad on 12/11/26.
//

import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var taskViewModel: TaskViewModel
    
    @State private var showingAddTask = false
    @State private var taskToEdit: TaskModel?
    
    init(userId: String) {
        _taskViewModel = StateObject(wrappedValue: TaskViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if taskViewModel.isLoading && taskViewModel.tasks.isEmpty {
                    ProgressView("Loading tasks...")
                } else if taskViewModel.tasks.isEmpty {
                    emptyStateView
                } else {
                    taskList
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive) {
                        authViewModel.logout()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                        .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                TaskFormView(taskViewModel: taskViewModel)
            }
            .sheet(item: $taskToEdit) { task in
                TaskFormView(taskViewModel: taskViewModel, taskToEdit: task)
            }
            .task {
                await taskViewModel.fetchTasks()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checklist")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("No Tasks Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("You're all caught up! Tap the + button to add your first task.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                showingAddTask = true
            } label: {
                Label("Add Task", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    private var taskList: some View {
        List {
            ForEach(taskViewModel.tasks) { task in
                HStack(alignment: .top, spacing: 12) {
                    // Checkbox button to mark complete/incomplete
                    Button {
                        Task {
                            await taskViewModel.toggleTaskCompletion(task)
                        }
                    } label: {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(task.isCompleted ? .green : .gray)
                    }
                    .buttonStyle(.plain)
                    
                    // Task title and description
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.headline)
                            .strikethrough(task.isCompleted, color: .secondary)
                            .foregroundColor(task.isCompleted ? .secondary : .primary)
                        
                        if !task.description.isEmpty {
                            Text(task.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Text(task.createdAt, style: .date)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    taskToEdit = task
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            await taskViewModel.deleteTask(task)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        taskToEdit = task
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.orange)
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await taskViewModel.fetchTasks()
        }
    }
}

#Preview {
    TodoListView(userId: "preview_user")
        .environmentObject(AuthViewModel())
}

