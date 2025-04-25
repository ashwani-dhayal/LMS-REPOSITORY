
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

@main
struct lmsApp: App {
  @StateObject private var authViewModel = AuthViewModel()

  init() {
    FirebaseApp.configure()
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(authViewModel)  // This is correct - make sure it's not missing
    }
  }
}
