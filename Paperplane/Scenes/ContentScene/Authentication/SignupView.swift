//
//  SignupView.swift
//  Paperplane
//
//  Created by tyler on 3/6/24.
//

import SwiftUI
import Combine

private enum FocusableField: Hashable {
  case email
  case password
  case confirmPassword
}

struct SignupView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focus: FocusableField?
    @State private var passwordVisible = false
    @State private var confirmPasswordVisible = false
    
    private func signUpWithEmailPassword() {
        Task {
            if await viewModel.signUpWithEmailPassword() == true {
                dismiss()
            }
        }
    }
    
    var body: some View {
        VStack {
            /*
             Image("SignUp")
             .resizable()
             .aspectRatio(contentMode: .fit)
             .frame(minHeight: 300, maxHeight: 400)
             */
            Text("Sign up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "at")
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .password
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 4)
            
            HStack {
                  Image(systemName: "lock")
                  if passwordVisible {
                      TextField("Password", text: $viewModel.password)
                          .focused($focus, equals: .password)
                          .submitLabel(.next)
                          .onSubmit {
                              self.focus = .confirmPassword
                          }
                  } else {
                      SecureField("Password", text: $viewModel.password)
                          .focused($focus, equals: .password)
                          .submitLabel(.next)
                          .onSubmit {
                              self.focus = .confirmPassword
                          }
                  }
                  Button(action: {
                      passwordVisible.toggle()
                  }) {
                      Image(systemName: passwordVisible ? "eye.slash" : "eye")
                  }
              }
              .padding(.vertical, 6)
              .background(Divider(), alignment: .bottom)
              .padding(.bottom, 8)
            
            HStack {
                Image(systemName: "lock")
                if confirmPasswordVisible {
                    TextField("Confirm password", text: $viewModel.confirmPassword)
                        .focused($focus, equals: .confirmPassword)
                        .submitLabel(.go)
                        .onSubmit {
                            signUpWithEmailPassword()
                        }
                } else {
                    SecureField("Confirm password", text: $viewModel.confirmPassword)
                        .focused($focus, equals: .confirmPassword)
                        .submitLabel(.go)
                        .onSubmit {
                            signUpWithEmailPassword()
                        }
                }
                Button(action: {
                    confirmPasswordVisible.toggle()
                }) {
                    Image(systemName: confirmPasswordVisible ? "eye.slash" : "eye")
                }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 8)
            
            
            if !viewModel.errorMessage.isEmpty {
                VStack {
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }
            
            Button(action: signUpWithEmailPassword) {
                if viewModel.authenticationState != .authenticating {
                    Text("Sign up")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(!viewModel.isValid)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            
            HStack {
                Text("Already have an account?")
                Button(action: { viewModel.switchFlow() }) {
                    Text("Log in")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding([.top, .bottom], 50)
            
        }
        .listStyle(.plain)
        .padding(.all, 50)
        .glassBackgroundEffect()
        .frame(width: 500, height: 500)
    }
}

struct SignupView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      SignupView()
        .preferredColorScheme(.dark)
    }
    .environmentObject(AuthenticationViewModel())
  }
}
