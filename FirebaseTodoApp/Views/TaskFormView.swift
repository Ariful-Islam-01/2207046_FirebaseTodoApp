//
//  TaskFormView.swift
//  FirebaseTodoApp
//
//  Created by Ashrafur Rahman Nihad on 12/11/26.
//

import SwiftUI

struct TaskFormView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    var taskToEdit: TaskModel?
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var isSaving: Bool = false
    
    var isEditing: Bool {
        taskToEdit != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Description (optional)")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                }
                
                if let errorMessage = taskViewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Save") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                }
            }
            .onAppear {
                if let task = taskToEdit {
                    title = task.title
                    description = task.description
                }
            }
        }
    }
    
    private func saveTask() {
        isSaving = true
        Task {
            let success: Bool
            if let task = taskToEdit {
                success = await taskViewModel.updateTask(
                    task: task,
                    newTitle: title,
                    newDescription: description
                )
            } else {
                success = await taskViewModel.addTask(
                    title: title,
                    description: description
                )
            }
            isSaving = false
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    TaskFormView(taskViewModel: TaskViewModel(userId: "preview_user"))
}

