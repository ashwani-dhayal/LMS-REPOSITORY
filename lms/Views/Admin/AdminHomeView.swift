//
//  AdminHomeView.swift
//  lms
//
//  Created by VR on 21/04/25.
//

import SwiftUI

struct AdminHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Text("Admin Home")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
            .navigationTitle("Admin Home")
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
