//
//  LibrarianHomeView.swift
//  lms
//
//  Created by VR on 21/04/25.
//

import SwiftUI

struct LibrarianHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Text("Librarian Home")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
            .navigationTitle("Librarian Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                }
            }
    }
}



