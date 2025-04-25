import Foundation
import Combine
import SwiftUI

struct LibrarianListView: View {
    @StateObject private var viewModel = LibrarianViewModel()
    @State private var showAddLibrarianView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Librarians")
                    .font(.system(size: 32, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                SearchBar(text: $viewModel.searchText)

                Button(action: {
                    showAddLibrarianView = true
                }) {
                    HStack {
                        Text("Add a New Librarian")
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredLibrarians) { librarian in
                            LibrarianRow(librarian: librarian, viewModel: viewModel)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showAddLibrarianView) {
                AddLibrarianView()
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(12)
        .background(Color(.white))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}


struct LibrarianRow: View {
    var librarian: Librarian
    var viewModel: LibrarianViewModel

    var body: some View {
        HStack(spacing: 16) {
            Image(librarian.profileImageURL)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))

            VStack(alignment: .leading, spacing: 4) {
                Text(librarian.name)
                    .font(.system(size: 18, weight: .semibold))
                Text(librarian.designation)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: {
                    viewModel.approveLibrarian(librarian)
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.green)
                        .clipShape(Circle())
                }

                Button(action: {
                    viewModel.deleteLibrarian(librarian)
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}


class LibrarianViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var librarians: [Librarian] = []
    
    var filteredLibrarians: [Librarian] {
        if searchText.isEmpty {
            return librarians
        } else {
            return librarians.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    init() {
        fetchLibrarians()
    }
    
    func fetchLibrarians() {
        self.librarians = [
            Librarian(id: UUID().uuidString, name: "Aishwarya", designation: "Assistant Librarian", salary: "45000", contact: "9876543210", email: "aishwarya@library.com", password: "secure123", profileImageURL: "avatar1"),
            Librarian(id: UUID().uuidString, name: "Rohan", designation: "Assistant Librarian", salary: "45000", contact: "9876543211", email: "rohan@library.com", password: "secure123", profileImageURL: "avatar2"),
            Librarian(id: UUID().uuidString, name: "Divya", designation: "Assistant Librarian", salary: "45000", contact: "9876543212", email: "divya@library.com", password: "secure123", profileImageURL: "avatar3"),
            Librarian(id: UUID().uuidString, name: "Nithya", designation: "Assistant Librarian", salary: "45000", contact: "9876543213", email: "nithya@library.com", password: "secure123", profileImageURL: "avatar4"),
            Librarian(id: UUID().uuidString, name: "Raman", designation: "Assistant Librarian", salary: "45000", contact: "9876543214", email: "raman@library.com", password: "secure123", profileImageURL: "avatar5")
        ]
    }
    
    func approveLibrarian(_ librarian: Librarian) {
        print("Approved: \(librarian.name)")
        // You can add approval status or logic here
    }
    
    func deleteLibrarian(_ librarian: Librarian) {
        if let index = librarians.firstIndex(where: { $0.id == librarian.id }) {
            librarians.remove(at: index)
            print("Deleted: \(librarian.name)")
        }
    }
}
