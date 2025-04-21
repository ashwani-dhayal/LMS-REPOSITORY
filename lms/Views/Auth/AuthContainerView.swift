//
//  AuthContainerView.swift
//  lms
//
//  Created by VR on 21/04/25.
//

import SwiftUI

struct AuthContainerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            OnboardingView()
                .environmentObject(authViewModel)
        }
    }
}
