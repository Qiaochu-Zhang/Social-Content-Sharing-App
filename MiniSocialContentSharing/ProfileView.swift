//  ProfileView.swift
//  Mini Social Content Sharing App
//
//  Created by Qiaochu Zhang on 9/10/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct ProfileView: View {
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var profileImageUrl: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var imagePickerPresented = false
    
    var body: some View {
        VStack {
            // Avatar display and editing
            if let imageUrl = URL(string: profileImageUrl) {
                AnyView(
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    } placeholder: {
                        ProgressView()
                    }
                )
                .onTapGesture {
                    imagePickerPresented = true
                }
            } else {
                // add avatar if there is none
                Button(action: {
                    imagePickerPresented = true
                }) {
                    Text("Add Profile Picture")
                        .foregroundColor(.blue)
                }
            }
            
            // Edit username
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Edit bio
            TextField("Bio", text: $bio)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Save button
            Button(action: {
                saveProfile()
            }) {
                Text("Save Profile")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .onAppear {
            loadProfile()
        }
        // Choose Sheet of the picture
        .sheet(isPresented: $imagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    // Load bio
    func loadProfile() {
        let db = Firestore.firestore()
            // Get current UID
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is logged in")
            return
        }
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                self.username = data?["username"] as? String ?? ""
                self.bio = data?["bio"] as? String ?? ""
                self.profileImageUrl = data?["profileImageUrl"] as? String ?? ""
            } else {
                print("User document does not exist")
            }
        }
    }
    
    // Save profile
    func saveProfile() {
        let db = Firestore.firestore()
            // Get current UID
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is logged in")
            return
        }
        if let selectedImage = selectedImage {
            // Upload avatar Firebase Storage
            uploadProfileImage(image: selectedImage) { imageUrl in
                if let imageUrl = imageUrl {
                    self.profileImageUrl = imageUrl
                    saveProfileToFirestore(userId: userId)
                }
            }
        } else {
            // Save other info to Firestore
            saveProfileToFirestore(userId: userId)
        }
    }
    
    // Upload avatar to Firebase Storage
    func uploadProfileImage(image: UIImage, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference().child("profile_images/\(UUID().uuidString).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG")
            completion(nil)
            return
        }
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url?.absoluteString)
            }
        }
    }
    
    // Save bio in Firestore
    func saveProfileToFirestore(userId: String) {
        let db = Firestore.firestore()
        let profileData: [String: Any] = [
            "username": username,
            "bio": bio,
            "profileImageUrl": profileImageUrl
        ]
        
        db.collection("users").document(userId).setData(profileData) { error in
            if let error = error {
                print("Error saving profile: \(error.localizedDescription)")
            } else {
                print("Profile saved successfully")
            }
        }
    }
}
