//
//  UserProfile.swift
//  Paperplane
//
//  Created by tyler on 3/6/24.
//

import SwiftUI

struct UserProfileView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel
  @Environment(\.dismiss) var dismiss
  @State var presentingConfirmationDialog = false

  private func deleteAccount() {
    Task {
      if await viewModel.deleteAccount() == true {
        dismiss()
      }
    }
  }

  private func signOut() {
    viewModel.signOut()
  }

    var body: some View {
        VStack {
            Form {
                profileImageSection
                emailSection
                signOutSection
                deleteAccountSection
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Deleting your account is permanent. Do you want to delete your account?",
                                isPresented: $presentingConfirmationDialog, titleVisibility: .visible) {
                Button("Delete Account", role: .destructive, action: deleteAccount)
                Button("Cancel", role: .cancel) {}
            }
        }
        .glassBackgroundEffect()
    }

    private var profileImageSection: some View {
        Section {
            VStack {
                profileImage
                editButton
            }
        }
        .listRowBackground(Color(UIColor.systemGroupedBackground))
    }
    
    private var profileImage: some View {
        HStack {
            Spacer()
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
            Spacer()
        }
    }
    
    private var editButton: some View {
        Button("Edit", action: {})
    }
    
    private var emailSection: some View {
        Section("Email") {
            Text(viewModel.displayName)
        }
    }
    
    private var signOutSection: some View {
        Section {
            centeredButton("Sign out", action: signOut)
        }
    }
    
    private var deleteAccountSection: some View {
        Section {
            centeredButton("Delete Account", role: .destructive) {
                presentingConfirmationDialog = true
            }
        }
    }
    
    private func centeredButton(_ title: String, role: ButtonRole? = nil, action: @escaping () -> Void) -> some View {
        Button(role: role, action: action) {
            HStack {
                Spacer()
                Text(title)
                Spacer()
            }
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      UserProfileView()
        .environmentObject(AuthenticationViewModel())
    }
  }
}
