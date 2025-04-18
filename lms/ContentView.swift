//
//  ContentView.swift
//  lms
//
//  Created by VR on 18/04/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "book")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Library Management System")
        }
        .padding()
    }
    
    
}

#Preview {
    ContentView()
}
