import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct AddBookView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var book = Book()
    @State private var pagesText: String = ""
    @State private var totalCopiesText: String = ""
    
    @State private var showingImageOptions = false
    @State private var activeSheet: ActiveSheet?
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Reference to Firestore
    private let db = Firestore.firestore()
    // Reference to Storage
    private let storage = Storage.storage()
    
    enum ActiveSheet: Identifiable {
        case camera, photoLibrary, datePicker
        
        var id: Int {
            switch self {
            case .camera: return 0
            case .photoLibrary: return 1
            case .datePicker: return 2
            }
        }
    }
    
    // Date formatter for displaying the release date
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(width: 150, height: 200)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        
                        if let image = book.coverImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Image(systemName: "camera")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 20)
                    .onTapGesture {
                        showingImageOptions = true
                    }
                    .actionSheet(isPresented: $showingImageOptions) {
                        ActionSheet(
                            title: Text("Add Book Cover"),
                            message: Text("Select a source"),
                            buttons: [
                                .default(Text("Camera")) {
                                    self.activeSheet = .camera
                                },
                                .default(Text("Photo Library")) {
                                    self.activeSheet = .photoLibrary
                                },
                                .cancel()
                            ]
                        )
                    }
                    
                    // Book Details Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("ENTER BOOK DETAILS")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 16)
                            .padding(.bottom, 10)
                        
                        BookDetailRow(icon: "barcode", label: "ISBN Number", value: $book.isbn)
                        BookDetailRow(icon: "book", label: "Book Title", value: $book.title)
                        BookDetailRow(icon: "person", label: "Author Name", value: $book.author)
                        BookDetailRow(icon: "theatermasks", label: "Genre", value: $book.genre)
                        
                        // Release Date Row with Date Picker
                        VStack {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar")
                                    .frame(width: 24)
                                    .foregroundColor(.gray)
                                
                                Text("Release Date")
                                    .font(.body)
                                
                                Spacer()
                                
                                Button(action: {
                                    activeSheet = .datePicker
                                }) {
                                    Text(dateFormatter.string(from: book.releaseDate))
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .contentShape(Rectangle())
                            
                            Divider()
                                .padding(.leading, 52)
                        }
                        
                        BookDetailRow(icon: "globe", label: "Language", value: $book.language)
                        
                        // Pages Row (Integer)
                        IntegerInputRow(
                            icon: "doc.text",
                            label: "Pages",
                            text: $pagesText,
                            value: $book.pages
                        )
                        
                        // Total Copies Row (Integer)
                        IntegerInputRow(
                            icon: "books.vertical",
                            label: "Total Copies",
                            text: $totalCopiesText,
                            value: $book.totalCopies
                        )
                        
                        BookDetailRow(icon: "location", label: "Book Location", value: $book.location)
                        BookDetailRow(icon: "doc.plaintext", label: "Book Summary", value: $book.summary, isMultiline: true)
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitle("Add a New Book", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back")
                        .foregroundColor(.blue)
                },
                trailing: Button(action: {
                    saveBookToFirebase()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Save")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .disabled(isLoading)
            )
            .sheet(item: $activeSheet) { item in
                switch item {
                case .camera:
                    ImagePicker(selectedImage: $book.coverImage, sourceType: .camera)
                case .photoLibrary:
                    ImagePicker(selectedImage: $book.coverImage, sourceType: .photoLibrary)
                case .datePicker:
                    DatePickerView(selectedDate: $book.releaseDate)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Book Status"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Firebase Functions
    
    func saveBookToFirebase() {
        // 1. Validate required fields
        guard !book.title.isEmpty, !book.author.isEmpty, !book.isbn.isEmpty else {
            alertMessage = "Please fill in at least the title, author, and ISBN fields."
            showAlert = true
            return
        }
        
        isLoading = true
        let bookRef = db.collection("books").document(book.isbn)
        
        // 2. Prevent duplicates
        bookRef.getDocument { (snapshot, error) in
            if let error = error {
                print("❌ Firestore getDocument error:", error)
                finishWithError("Unable to check ISBN: \(error.localizedDescription)")
                return
            }
            
            if snapshot?.exists == true {
                finishWithError("A book with this ISBN already exists.")
                return
            }
            
            // 3. Upload cover image if present
            if let image = book.coverImage,
               let jpegData = image.jpegData(compressionQuality: 0.7) {
                
                let storageRef = storage.reference().child("bookCovers/\(book.isbn).jpg")
                let meta = StorageMetadata()
                meta.contentType = "image/jpeg"
                
                storageRef.putData(jpegData, metadata: meta) { _, err in
                    if let err = err {
                        print("❌ Storage upload error:", err)
                        finishWithError("Image upload failed: \(err.localizedDescription)")
                        return
                    }
                    
                    storageRef.downloadURL { url, err in
                        if let err = err {
                            print("❌ DownloadURL error:", err)
                            finishWithError("Couldn't get image URL: \(err.localizedDescription)")
                        } else {
                            saveBookData(to: bookRef, imageURL: url?.absoluteString)
                        }
                    }
                }
            } else {
                // No cover image
                saveBookData(to: bookRef, imageURL: nil)
            }
        }
    }
    
    private func saveBookData(to ref: DocumentReference, imageURL: String?) {
        // 4. Prepare your data dictionary with proper types
        var data: [String: Any] = [
            "isbn": book.isbn,
            "title": book.title,
            "author": book.author,
            "genre": book.genre,
            "releaseDate": Timestamp(date: book.releaseDate), // Convert Date to Timestamp
            "language": book.language,
            "pages": book.pages, // Now an integer
            "totalCopies": book.totalCopies, // Now an integer
            "availableCopies": book.totalCopies, // Initialize available = total
            "location": book.location,
            "summary": book.summary,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        if let url = imageURL {
            data["coverImageURL"] = url
        }
        
        // 5. Write to Firestore
        ref.setData(data) { err in
            if let err = err {
                print("❌ Firestore setData error:", err)
                finishWithError("Error saving book: \(err.localizedDescription)")
            } else {
                alertMessage = "Book successfully added to library!"
                showAlert = true
                
                // Dismiss after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isLoading = false
                    resetForm()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    // Helper to show errors uniformly
    private func finishWithError(_ msg: String) {
        DispatchQueue.main.async {
            isLoading = false
            alertMessage = msg
            showAlert = true
        }
    }
    
    // Reset form after submission
    private func resetForm() {
        book = Book()
        pagesText = ""
        totalCopiesText = ""
    }
}

// MARK: - Supporting Views

struct BookDetailRow: View {
    let icon: String
    let label: String
    @Binding var value: String
    var isMultiline: Bool = false
    @State private var isEditing = false
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundColor(.gray)
                
                Text(label)
                    .font(.body)
                
                Spacer()
                
                if isMultiline && isEditing {
                    // Don't show anything here when multiline editing is active
                } else if isEditing {
                    TextField("", text: $value)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: UIScreen.main.bounds.width / 2.5)
                        .placeholder(when: value.isEmpty) {
                            Text("Value")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                        }
                } else {
                    Text(value.isEmpty ? "Value" : value)
                        .foregroundColor(value.isEmpty ? .gray : .primary)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(isMultiline ? 1 : nil)
                        .truncationMode(.tail)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color.white)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isEditing = true
                }
            }
            
            if isMultiline && isEditing {
                TextEditor(text: $value)
                    .frame(minHeight: 100)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                Button(action: {
                    withAnimation {
                        isEditing = false
                    }
                }) {
                    Text("Done")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(BorderlessButtonStyle())
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            
            Divider()
                .padding(.leading, 52)
        }
    }
}

// Add integer input row (for Pages and Total Copies)
struct IntegerInputRow: View {
    let icon: String
    let label: String
    @Binding var text: String
    @Binding var value: Int
    @State private var isEditing = false
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundColor(.gray)
                
                Text(label)
                    .font(.body)
                
                Spacer()
                
                if isEditing {
                    TextField("", text: $text)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: UIScreen.main.bounds.width / 2.5)
                        .placeholder(when: text.isEmpty) {
                            Text("0")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                        }
                        .onChange(of: text) { newValue in
                            // Convert to integer
                            value = Int(newValue) ?? 0
                        }
                } else {
                    Text(value == 0 ? "0" : "\(value)")
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.trailing)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color.white)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isEditing = true
                    // Initialize text field with current value when editing starts
                    if value > 0 && text.isEmpty {
                        text = "\(value)"
                    }
                }
            }
            
            Divider()
                .padding(.leading, 52)
        }
    }
}

// Date Picker View
struct DatePickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedDate: Date
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select a date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationBarTitle("Book Release Date", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// Image Picker
//struct ImagePicker: UIViewControllerRepresentable {
//    @Binding var selectedImage: UIImage?
//    var sourceType: UIImagePickerController.SourceType
//    
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.sourceType = sourceType
//        picker.delegate = context.coordinator
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//        let parent: ImagePicker
//        
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//        
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let image = info[.originalImage] as? UIImage {
//                parent.selectedImage = image
//            }
//            picker.dismiss(animated: true)
//        }
//        
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            picker.dismiss(animated: true)
//        }
//    }
//}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct AddBookView_Previews: PreviewProvider {
    static var previews: some View {
        AddBookView()
    }
}
