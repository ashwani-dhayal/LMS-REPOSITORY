//
//  UserHomeView.swift
//  lms
//
//  Created by VR on 21/04/25.
//

import SwiftUI

struct UserHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Text("User Home")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
            .navigationTitle("User Home")
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
