//
//  LoginView.swift
//  Paperplane
//
//  Created by tyler on 3/6/24.
//
import SwiftUI
import FirebaseAuth

private enum FocusableField: Hashable {
  case email
  case password
}

/*
 struct LoginView: View {
 @EnvironmentObject var authViewModel: AuthenticationViewModel
 @Environment(\.dismiss) var dismiss
 
 @State private var email = ""
 @State private var password = ""
 
 private func signInWithEmailPassword() {
 Task {
 if await viewModel.signInWithEmailPassword() == true {
 dismiss()
 }
 }
 }
 
 var body: some View {
 VStack {
 Text("Login")
 .font(.largeTitle)
 .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
 TextField("Email", text: $email)
 .textFieldStyle(RoundedBorderTextFieldStyle())
 .autocapitalization(.none)
 .keyboardType(.emailAddress)
 SecureField("Password", text: $password)
 .textFieldStyle(RoundedBorderTextFieldStyle())
 Button("Login") {
 authViewModel.loginWithEmail(email: email, password: password)
 }
 .padding()
 // GoogleSignInButton(action: handleGoogleSignIn)
 }
 .padding(.all, 50)
 .glassBackgroundEffect()
 .frame(width: 500, height: 500)
 }
 
 func handleGoogleSignIn() {
 return
 /*
  GIDSignIn.sharedInstance.signIn(withPresenting: self)
  { authentication, error in
  guard let user = authentication?.user, let idToken = user.idToken?.tokenString else { return }
  let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
  authManager.signInWithGoogle(credentials: credential)
  }
  */
 }
 }
 
 #Preview {
 LoginView()
 }
 */

struct LoginView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel
  @Environment(\.dismiss) var dismiss

  @FocusState private var focus: FocusableField?

  private func signInWithEmailPassword() {
    Task {
      if await viewModel.signInWithEmailPassword() == true {
        dismiss()
      }
    }
  }

  var body: some View {
    VStack {
        /*
      Image("Login")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(minHeight: 300, maxHeight: 400)
         */
      Text("Login")
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
        SecureField("Password", text: $viewModel.password)
          .focused($focus, equals: .password)
          .submitLabel(.go)
          .onSubmit {
            signInWithEmailPassword()
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

      Button(action: signInWithEmailPassword) {
        if viewModel.authenticationState != .authenticating {
          Text("Login")
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
        Text("Don't have an account yet?")
        Button(action: { viewModel.switchFlow() }) {
          Text("Sign up")
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

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      LoginView()
      LoginView()
        .preferredColorScheme(.dark)
    }
    .environmentObject(AuthenticationViewModel())
  }
}
 
