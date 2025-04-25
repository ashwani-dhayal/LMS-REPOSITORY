//
//  DATAMODEL.swift
//  lms
//
//  Created by user@71 on 24/04/25.
//

import UIKit
import Foundation


//ADD A NEW BOOK VIEW SCREEN
struct Book {
    var isbn: String
    var title: String
    var author: String
    var genre: String
    var releaseDate: Date
    var language: String
    var pages: Int
    var totalCopies: Int
    var location: String
    var summary: String
    var coverImage: UIImage?
    
    init(isbn: String = "",
         title: String = "",
         author: String = "",
         genre: String = "",
         releaseDate: Date = Date(),
         language: String = "",
         pages: Int = 0,
         totalCopies: Int = 0,
         location: String = "",
         summary: String = "",
         coverImage: UIImage? = nil) {
        self.isbn = isbn
        self.title = title
        self.author = author
        self.genre = genre
        self.releaseDate = releaseDate
        self.language = language
        self.pages = pages
        self.totalCopies = totalCopies
        self.location = location
        self.summary = summary
        self.coverImage = coverImage
    }
}




//ADMIN HOME VIEW SCREEN
struct AdminStats {
    let booksCount: String
    let librariansCount: String
    let revenue: String
    let membersCount: String
    
    static let sampleData = AdminStats(
        booksCount: "12,233",
        librariansCount: "176",
        revenue: "$4,134",
        membersCount: "1,644"
    )
}

struct TabItem: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    var isSelected: Bool
    
    static let tabItems = [
        TabItem(icon: "chart.pie.fill", label: "Summary", isSelected: true),
        TabItem(icon: "person.text.rectangle.fill", label: "Librarian", isSelected: false),
        TabItem(icon: "person.3.fill", label: "Members", isSelected: false),
        TabItem(icon: "books.vertical.fill", label: "Library", isSelected: false)
    ]
}





//ADD LIBRARIAN VIEW SCREEN
struct Librarian: Identifiable {
    var id: String = UUID().uuidString
    var name: String = ""
    var designation: String = ""
    var salary: String = ""
    var contact: String = ""
    var email: String = ""
    var password: String = ""
    var profileImageURL: String = ""
}






//LIBRARIAN SCREEN(admin side)

