//
//  lmsApp.swift
//  lms
//
//  Created by VR on 18/04/25.
//

import FirebaseAuth
import FirebaseCore
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
        .environmentObject(authViewModel)
    }
  }
}
