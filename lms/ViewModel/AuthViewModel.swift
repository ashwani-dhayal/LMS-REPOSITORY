//
//  AuthViewModel.swift
//  lms
//
//  Created by VR on 21/04/25.

import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI

enum UserRole: String {
    case admin
    case librarian
    case user
}

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var userRole: UserRole = .user
    @Published var isLoading = false

    private let db = Firestore.firestore()

    init() {

        if let currentUser = Auth.auth().currentUser {
            self.user = currentUser
            self.isAuthenticated = true
            self.fetchUserRole()
        }
    }

    func fetchUserRole() {
        guard let userId = user?.uid else { return }
        isLoading = true

        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            if let document = document, document.exists {
                if let roleString = document.data()?["role"] as? String,
                    let role = UserRole(rawValue: roleString)
                {
                    DispatchQueue.main.async {
                        self.userRole = role
                    }
                }
            }
        }
    }

    func signUp(email: String, password: String, role: UserRole = .user) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            if let user = result?.user {
                self.user = user
                self.isAuthenticated = true
                self.userRole = role

                let userData: [String: Any] = [
                    "email": email,
                    "role": role.rawValue,
                    "createdAt": Date(),
                ]

                self.db.collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    func signIn(email: String, password: String) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            if let user = result?.user {
                self.user = user
                self.isAuthenticated = true
                self.fetchUserRole()
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isAuthenticated = false
            self.userRole = .user
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
