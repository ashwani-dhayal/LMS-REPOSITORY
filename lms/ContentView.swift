import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            if authViewModel.isLoading {
                ProgressView("Loading...")
            } else if authViewModel.isAuthenticated {
                switch authViewModel.userRole {
                case .admin:
                    AdminHomeView()
                        .environmentObject(authViewModel)
                case .librarian:
                    LibrarianHomeView()
                        .environmentObject(authViewModel)
                case .user:
                    AdminHomeView()
                        .environmentObject(authViewModel)
                }
            } else {
                AuthContainerView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
