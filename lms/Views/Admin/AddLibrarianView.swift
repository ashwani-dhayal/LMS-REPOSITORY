import SwiftUI
import FirebaseFirestore
import FirebaseStorage



struct AddLibrarianView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var librarian = Librarian()
    @State private var profileImage: UIImage?
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // Firebase references
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // State for handling save operation
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Profile Image
                    Button(action: {
                        showImagePicker = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 120, height: 120)
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                            
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 118, height: 118)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "camera")
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Form Fields
                    VStack(spacing: 0) {
                        FormField(icon: "person", label: "Name", placeholder: "Enter name", text: $librarian.name)
                        Divider()
                        FormField(icon: "tag", label: "Designation", placeholder: "Enter designation", text: $librarian.designation)
                        Divider()
                        FormField(icon: "dollarsign", label: "Salary", placeholder: "Enter salary", text: $librarian.salary)
                            .keyboardType(.decimalPad)
                        Divider()
                        FormField(icon: "phone", label: "Contact", placeholder: "Enter contact number", text: $librarian.contact)
                            .keyboardType(.phonePad)
                        Divider()
                        FormField(icon: "envelope", label: "Email", placeholder: "Enter email", text: $librarian.email)
                            .keyboardType(.emailAddress)
                        Divider()
                        FormField(icon: "lock", label: "Password", placeholder: "Enter password", text: $librarian.password, isSecure: true)
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
                
                if isLoading {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Saving...")
                            .foregroundColor(.white)
                            .padding(.top, 10)
                            .font(.headline)
                    }
                }
            }
            .navigationBarTitle("Add Librarian", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                },
                trailing: Button(action: {
                    saveLibrarianToFirebase()
                }) {
                    Text("Save")
                        .foregroundColor(.blue)
                }
                .disabled(isLoading)
            )
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $profileImage, sourceType: sourceType)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Librarian Status"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func saveLibrarianToFirebase() {
        // Validate fields
        guard !librarian.name.isEmpty, !librarian.email.isEmpty, !librarian.password.isEmpty else {
            alertMessage = "Please fill in at least the name, email, and password fields."
            showAlert = true
            return
        }
        
        // Validate email format
        if !isValidEmail(librarian.email) {
            alertMessage = "Please enter a valid email address."
            showAlert = true
            return
        }
        
        isLoading = true
        
        // Create a document reference with the librarian's ID
        let librarianRef = db.collection("librarians").document(librarian.id)
        
        // If there's a profile image, upload it first
        if let profileImage = profileImage, let imageData = profileImage.jpegData(compressionQuality: 0.7) {
            let storageRef = storage.reference().child("librarianProfiles/\(librarian.id).jpg")
            
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    isLoading = false
                    alertMessage = "Error uploading image: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let error = error {
                        isLoading = false
                        alertMessage = "Error getting download URL: \(error.localizedDescription)"
                        showAlert = true
                        return
                    }
                    
                    if let downloadURL = url {
                        // Update the librarian model with image URL
                        var updatedLibrarian = librarian
                        updatedLibrarian.profileImageURL = downloadURL.absoluteString
                        
                        // Save librarian data with image URL
                        saveLibrarianData(updatedLibrarian, to: librarianRef)
                    }
                }
            }
        } else {
            // Add librarian data without image
            saveLibrarianData(librarian, to: librarianRef)
        }
    }
    
    private func saveLibrarianData(_ librarian: Librarian, to librarianRef: DocumentReference) {
        // Create librarian data dictionary
        let librarianData: [String: Any] = [
            "id": librarian.id,
            "name": librarian.name,
            "designation": librarian.designation,
            "salary": librarian.salary,
            "contact": librarian.contact,
            "email": librarian.email,
            "password": librarian.password, // Note: In a production app, you should hash the password or use Firebase Auth
            "profileImageURL": librarian.profileImageURL,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        // Set data to Firestore
        librarianRef.setData(librarianData) { error in
            isLoading = false
            
            if let error = error {
                alertMessage = "Error saving librarian: \(error.localizedDescription)"
                showAlert = true
            } else {
                // Update the librarians count in AdminStats collection
                updateLibrarianCount()
                
                alertMessage = "Librarian successfully added!"
                showAlert = true
                
                // Clear form after successful save
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    clearForm()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func updateLibrarianCount() {
        // Get the current count
        let statsRef = db.collection("adminStats").document("stats")
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let statsDocument: DocumentSnapshot
            do {
                try statsDocument = transaction.getDocument(statsRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldCount = statsDocument.data()?["librariansCount"] as? String else {
                // If document doesn't exist or doesn't have librariansCount field, create it
                transaction.setData(["librariansCount": "1"], forDocument: statsRef, merge: true)
                return nil
            }
            
            // Remove any non-numeric characters and convert to int
            let numericCount = oldCount.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            guard let countValue = Int(numericCount) else {
                transaction.setData(["librariansCount": "1"], forDocument: statsRef, merge: true)
                return nil
            }
            
            // Format the new count with commas
            let newCount = countValue + 1
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let formattedCount = numberFormatter.string(from: NSNumber(value: newCount)) ?? String(newCount)
            
            transaction.updateData(["librariansCount": formattedCount], forDocument: statsRef)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Error updating librarians count: \(error)")
            }
        }
    }
    
    private func clearForm() {
        librarian = Librarian()
        profileImage = nil
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct FormField: View {
    var icon: String
    var label: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.gray)
            
            Text(label)
                .foregroundColor(.black)
                .frame(width: 100, alignment: .leading)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}
struct AddLibrarianView_Previews: PreviewProvider {
    static var previews: some View {
        AddLibrarianView()
    }
}








