//
//  SigninView.swift
//  lms
//
//  Created by VR on 18/04/25.
//

import SwiftUI

struct SigninView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var showPassword: Bool = false
    @Environment(\.dismiss) private var dismiss

    private var isFormValid: Bool {

        guard !email.isEmpty else {
            return false
        }

        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        guard email.range(of: emailRegex, options: .regularExpression) != nil else {
            return false
        }

        guard !password.isEmpty else {
            return false
        }

        return true
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Login with your account credentials.")
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)

                if let errorMessage = authViewModel.errorMessage {
                  // TODO: Implement this stuff
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .fontWeight(.medium)

                    HStack {
                        Image(systemName: "at")
                            .foregroundColor(.gray)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Password")
                            .fontWeight(.medium)
                        Spacer()
                    }

                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)

                        if showPassword {
                            TextField("Password", text: $password)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Password", text: $password)
                        }

                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.fill" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }

                HStack {
                    Button(action: {
                        rememberMe.toggle()
                    }) {
                        HStack {
                            Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                .foregroundColor(rememberMe ? .blue : .gray)
                                .imageScale(.large)

                            Text("Remember me")
                                .foregroundColor(.black)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 5)

                Button(action: {

                    authViewModel.errorMessage = nil

                    if isFormValid {
                        authViewModel.signIn(email: email, password: password)

                    } else {

                        if email.isEmpty {
                            authViewModel.errorMessage = "Email cannot be empty"
                        } else {
                            let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
                            if email.range(of: emailRegex, options: .regularExpression) == nil {
                                authViewModel.errorMessage = "Please enter a valid email address"
                            } else if password.isEmpty {
                                authViewModel.errorMessage = "Password cannot be empty"
                            }
                        }
                    }
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Login")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid && !authViewModel.isLoading ? Color.black : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(authViewModel.isLoading || !isFormValid)
                .padding(.vertical)
                .padding(.top, 10)

                HStack {
                    Spacer()

                    Text("Don't have a member account?")
                        .foregroundColor(.gray)

                    NavigationLink(destination: SignupView()) {
                        Text("Create one!")
                            .foregroundColor(.blue)
                    }

                    Spacer()
                }
                .padding(.top, 10)

                Spacer()

            }
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct SigninView_Previews: PreviewProvider {
    static var previews: some View {
        SigninView()
    }
}
