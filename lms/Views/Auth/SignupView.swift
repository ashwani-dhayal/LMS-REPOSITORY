//
//  SignupView.swift
//  lms
//
//  Created by VR on 18/04/25.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var agreeToTerms: Bool = false
    @State private var showPassword: Bool = false
    @Environment(\.dismiss) private var dismiss

    private var isFormValid: Bool {

        guard !name.isEmpty else {
            return false
        }

        guard !email.isEmpty else {
            return false
        }

        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        guard email.range(of: emailRegex, options: .regularExpression) != nil else {
            return false
        }

        guard !password.isEmpty && password.count >= 6 else {
            return false
        }

        return true
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Register")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Enter your details below to create a new account.")
                    .foregroundColor(.gray)

                if let errorMessage = authViewModel.errorMessage {
                  // TODO: Implement this stuff
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .fontWeight(.medium)

                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.gray)
                        TextField("Enter your name", text: $name)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .fontWeight(.medium)

                    HStack {
                        Image(systemName: "at")
                            .foregroundColor(.gray)
                        TextField("Enter your email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .fontWeight(.medium)

                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)

                        if showPassword {
                            TextField("Enter your password", text: $password)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Enter your password", text: $password)
                                .autocapitalization(.none)
                        }

                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.fill" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                HStack(alignment: .center) {
                    Toggle("", isOn: $agreeToTerms)
                        .labelsHidden()
                        .toggleStyle(CheckboxToggleStyle())

                    Text("Agree with Terms and Conditions")
                        .fontWeight(.medium)
                }
                .padding(.vertical)

                Button(action: {
                    if isFormValid && agreeToTerms {
                        authViewModel.signUp(email: email, password: password)
                    }
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Continue")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    isFormValid && agreeToTerms && !authViewModel.isLoading
                        ? Color.black : Color.gray
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!isFormValid || !agreeToTerms || authViewModel.isLoading)
                .padding(.top)

                Spacer()

            }
            .padding(.horizontal)
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .blue : .gray)
                .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                .imageScale(.large)
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
