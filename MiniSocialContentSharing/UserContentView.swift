//
//  UserContentView.swift
//  Mini Social Content Sharing App
//
//  Created by Qiaochu Zhang on 9/10/24.
//

import SwiftUI
import FirebaseFirestore

import FirebaseAuth
/*
struct UserContentView_Previews: PreviewProvider {
    static var previews: some View {
        UserContentView()
    }
}
 */


struct UserContentView: View {
    @State private var contentItems: [ContentItem] = []
    
    var body: some View {
        VStack {
            Text("Your Posts")
                .font(.title)
                .padding()
            
            List(contentItems) { item in
                VStack(alignment: .leading) {
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
                    
                    Text(item.description)
                        .font(.body)
                        .padding(.top, 5)
                }
            }
            .onAppear {
                fetchUserContent()
            }
        }
    }
    
    func fetchUserContent() {
        let db = Firestore.firestore()
        //let username = "CurrentUser"  // Replace with the real user ID
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is logged in")
            return
        }
        
        db.collection("contents").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user content: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            self.contentItems = documents.compactMap { doc -> ContentItem? in
                let data = doc.data()
                print("Document data: \(data)")
                guard let imageUrl = data["imageUrl"] as? String,
                      let description = data["description"] as? String,
                      let likes = data["likes"] as? Int,
                      let commentsData = data["comments"] as? [[String: String]] else {
                    return nil
                }
                
                // Convert comments from dictionaries to Comment objects
                let comments = commentsData.compactMap { dict -> Comment? in
                    guard let username = dict["username"], let comment = dict["comment"] else {
                        return nil
                    }
                    return Comment(username: username, comment: comment)
                }
                
                return ContentItem(id: doc.documentID, imageUrl: imageUrl, description: description, likes: likes, comments: comments)
            }
        }
    }
}

struct ContentItem: Identifiable {
    var id: String
    var imageUrl: String
    var description: String
    var likes: Int
    var comments: [Comment]
}

struct Comment: Hashable {
    var username: String
    var comment: String
}
