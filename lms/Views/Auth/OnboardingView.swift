//
//  OnboardingView.swift
//  lms
//
//  Created by VR on 21/04/25.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Clean white background
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                // Content overlay
                VStack {
                    Spacer()
                    
                    // App logo and title
                    VStack(spacing: 15) {
                        Image("books")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.black)
                        
                        Text("Welcome to InfyReads")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.red.opacity(0.8))
                        .frame(width: 25, height: 25)
                    
                    Spacer()
                    
                    // Login buttons
                    VStack(spacing: 16) {
                        // NavigationLink to AdminLoginView
                        NavigationLink(destination: SigninView()) {
                            Text("Login")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        
                        // NavigationLink to RegisterView
                        NavigationLink(destination: SignupView()) {
                            Text("Sign Up")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: 20)
                    
                }
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
