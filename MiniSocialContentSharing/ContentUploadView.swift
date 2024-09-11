//
//  ContentUploadView.swift
//  Mini Social Content Sharing App
//
//  Created by Qiaochu Zhang on 9/9/24.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

// Define a wrapper for the image picker using PHPickerViewController
struct PHPickerViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    // Coordinator is used to handle the selection result
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Create UIImagePickerController
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images  // Only allow image selection
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator  // Set the delegate
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    // Coordinator is used to handle the user's image selection
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PHPickerViewControllerRepresentable

        init(_ parent: PHPickerViewControllerRepresentable) {
            self.parent = parent
        }

        // Handle the image selection result
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            // Retrieve the image from the result
            if let result = results.first {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedImage = image  // Update the bound image
                        }
                    }
                }
            }
        }
    }
}

struct ContentUploadView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var imagePickerPresented = false
    @State private var description: String = ""
    @State private var isUploading = false  // Handle upload status
    
    var body: some View {
        VStack {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding()
            } else {
                Button(action: {
                    imagePickerPresented = true
                }) {
                    Text("Select an Image")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            TextField("Enter a description", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if isUploading {
                ProgressView("Uploading...")  // Show upload progress
            } else {
                Button(action: {
                    if let selectedImage = selectedImage {
                        uploadContent(image: selectedImage, description: description)
                    }
                }) {
                    Text("Upload")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(selectedImage == nil || description.isEmpty)  // Disable button if no image or description is provided
            }
        }
        .sheet(isPresented: $imagePickerPresented) {
            PHPickerViewControllerRepresentable(selectedImage: $selectedImage)
        }
        .padding()
    }
    
    func uploadContent(image: UIImage, description: String) {
        isUploading = true  // Start upload, set upload status to true
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("images/\(imageName).jpg")
        
        // Convert UIImage to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("Failed to convert image to JPEG")
            isUploading = false
            return
        }
        
        // Upload the image to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                isUploading = false
                return
            }
            
            print("Image uploaded successfully")
            
            // Get the download URL
            storageRef.downloadURL { result in
                switch result {
                case .success(let url):  // On success, unpack the URL
                    print("Image URL: \(url.absoluteString)")
                    let imageUrlString = url.absoluteString  // Convert NSURL to String

                    // Get the current user's UID
                    guard let userId = Auth.auth().currentUser?.uid else {
                        print("No user is logged in")
                        isUploading = false
                        return
                    }

                    // Save the image URL and description to Firestore
                    let db = Firestore.firestore()
                    let contentData = [
                        "imageUrl": imageUrlString,
                        "description": description,
                        "likes": 0,
                        "comments": [],
                        "timestamp": Timestamp(),
                        "userId": userId,
                    ] as [String: Any]

                    print("Saving content data to Firestore: \(contentData)")
                    
                    db.collection("contents").addDocument(data: contentData) { error in
                        if let error = error {
                            print("Failed to save content to Firestore: \(error.localizedDescription)")
                        } else {
                            print("Content uploaded successfully to Firestore")
                        }
                        isUploading = false  // After upload, reset upload status
                        selectedImage = nil  // Reset selected image
                    }

                case .failure(let error):  // Handle error
                    print("Failed to get download URL: \(error.localizedDescription)")
                    isUploading = false
                }
            }
        }
    }
}
