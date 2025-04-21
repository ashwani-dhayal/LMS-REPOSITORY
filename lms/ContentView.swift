//
//  ContentView.swift
//  lms
//
//  Created by VR on 18/04/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            if authViewModel.isLoading {
                ProgressView("Loading...")
            } else if authViewModel.isAuthenticated {
                switch authViewModel.userRole {
                case .admin:
                    AdminHomeView()
                        .environmentObject(authViewModel)
                case .librarian:
                    LibrarianHomeView()
                        .environmentObject(authViewModel)
                case .user:
                    UserHomeView()
                        .environmentObject(authViewModel)
                }
            } else {
                AuthContainerView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
