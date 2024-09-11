//
//  ContentListView.swift
//  Mini Social Content Sharing App
//
//  Created by Qiaochu Zhang on 9/10/24.
//

import SwiftUI
import FirebaseFirestore

struct ContentListView: View {
    @State private var contentItems: [ContentItem] = []
    @State private var isLoading = true
    @State private var newComment = ""

    var body: some View {
        NavigationView {
            List(contentItems) { item in
                VStack(alignment: .leading) {
                    // Display image
                    if let imageUrl = URL(string: item.imageUrl) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 200)
                        .cornerRadius(10)
                    }

                    // Display description
                    Text(item.description)
                        .font(.body)
                        .padding(.top, 5)

                    // Like button and display likes count
                    HStack {
                        Text("Likes: \(item.likes)")
                        Spacer()
                        Button(action: {
                            likeContent(contentID: item.id, currentLikes: item.likes)
                        }) {
                            Image(systemName: "hand.thumbsup.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 10)

                    // Display list of comments
                    VStack(alignment: .leading) {
                        ForEach(item.comments, id: \.self) { comment in
                            Text("\(comment.username): \(comment.comment)")
                                .font(.subheadline)
                                .padding(.top, 2)
                        }

                        // Add comment section
                        HStack {
                            TextField("Add a comment...", text: $newComment)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: {
                                addComment(contentID: item.id, comment: newComment)
                                newComment = "" // Clear input field
                            }) {
                                Text("Post")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.top, 5)
                }
                .padding()
            }
            .navigationTitle("Content Feed")
            .onAppear {
                fetchContent()
            }
        }
    }

    func fetchContent() {
        let db = Firestore.firestore()

        // Fetch content from Firestore
        db.collection("contents").order(by: "timestamp", descending: true).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching content: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            // Process the fetched documents and update the content list
            self.contentItems = documents.compactMap { doc -> ContentItem? in
                let data = doc.data()
                guard let imageUrl = data["imageUrl"] as? String,
                      let description = data["description"] as? String,
                      let likes = data["likes"] as? Int,
                      let comments = data["comments"] as? [[String: String]] else {
                    return nil
                }

                // Convert comments to Comment objects
                let commentObjects = comments.compactMap { dict -> Comment? in
                    guard let username = dict["username"], let comment = dict["comment"] else {
                        return nil
                    }
                    return Comment(username: username, comment: comment)
                }

                return ContentItem(id: doc.documentID, imageUrl: imageUrl, description: description, likes: likes, comments: commentObjects)
            }
            self.isLoading = false
        }
    }

    // Update likes count
    func likeContent(contentID: String, currentLikes: Int) {
        let db = Firestore.firestore()
        let contentRef = db.collection("contents").document(contentID)

        contentRef.updateData([
            "likes": currentLikes + 1
        ]) { error in
            if let error = error {
                print("Error updating likes: \(error.localizedDescription)")
            }
        }
    }

    // Add a comment
    func addComment(contentID: String, comment: String) {
        let db = Firestore.firestore()
        let contentRef = db.collection("contents").document(contentID)

        contentRef.updateData([
            "comments": FieldValue.arrayUnion([["username": "CurrentUser", "comment": comment]])
        ]) { error in
            if let error = error {
                print("Error adding comment: \(error.localizedDescription)")
            }
        }
    }
}
