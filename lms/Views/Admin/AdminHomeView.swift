import SwiftUI



struct AdminHomeView: View {
    @State private var showAddBookView = false
    @State private var showAddLibrarianView = false
    @State private var selectedTab = "Summary"
    private let stats = AdminStats.sampleData
    @State private var tabs = TabItem.tabItems
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Show the correct view based on selected tab
                    if selectedTab == "Summary" {
                        // Summary View Content
                        summaryView
                    } else if selectedTab == "Librarian" {
                        // Using your existing LibrarianListView
                        LibrarianListView()
                    } else if selectedTab == "Members" {
                        Text("Members View Coming Soon")
                            .font(.title)
                            .foregroundColor(.gray)
                    } else if selectedTab == "Library" {
                        Text("Library View Coming Soon")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer(minLength: 20)
                    
                    // Improved Tab Bar
                    ImprovedTabBar(tabs: $tabs, selectedTab: $selectedTab)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddBookView) {
            AddBookView()
        }
        .sheet(isPresented: $showAddLibrarianView) {
            AddLibrarianView()
        }
    }
    
    // Extract the summary view into a separate variable
    private var summaryView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Summary")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 8)
                .padding(.leading, 16)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(title: "BOOKS", value: stats.booksCount, suffix: "/mo")
                        StatCard(title: "LIBRARIANS", value: stats.librariansCount, suffix: "/mo")
                        StatCard(title: "REVENUE", value: stats.revenue, suffix: "/mo")
                        StatCard(title: "MEMBERS", value: stats.membersCount, suffix: "/mo")
                    }
                    .padding(.horizontal, 16)
                    
                    // Action Buttons
                    Button(action: {
                        showAddLibrarianView = true
                    }) {
                        ActionButtonView(title: "Add a Librarian", icon: "person")
                    }
                    .padding(.horizontal, 16)
                    
                    Button(action: {
                        showAddBookView = true
                    }) {
                        ActionButtonView(title: "Add a Book", icon: "book")
                    }
                    .padding(.horizontal, 16)
                    
                    // Extra space at bottom for scrolling
                    Spacer(minLength: 250)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let suffix: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
                
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(suffix)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 2)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct ActionButtonView: View {
    let title: String
    let icon: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            HStack {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct ImprovedTabBar: View {
    @Binding var tabs: [TabItem]
    @Binding var selectedTab: String
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Button(action: {
                    // Deselect all tabs first
                    for i in tabs.indices {
                        tabs[i].isSelected = false
                    }
                    // Select this tab
                    tabs[index].isSelected = true
                    selectedTab = tabs[index].label
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].icon)
                            .font(.system(size: 22))
                            .foregroundColor(tabs[index].isSelected ? .white : .gray.opacity(0.7))
                        
                        Text(tabs[index].label)
                            .font(.system(size: 11))
                            .fontWeight(.medium)
                            .foregroundColor(tabs[index].isSelected ? .white : .gray.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.bottom)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct AdminHomeView_Previews: PreviewProvider {
    static var previews: some View {
        AdminHomeView()
    }
}
