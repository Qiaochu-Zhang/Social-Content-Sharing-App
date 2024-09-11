# Mini Social Content Sharing App

This is a simple SwiftUI-based social content sharing app, using Firebase for authentication, Firestore for storing content and user information, and Firebase Storage for uploading and managing images.

## Features
- User authentication using Firebase Authentication.
- Upload images and descriptions to Firebase Storage and Firestore.
- Display content (including images and text) from Firestore.
- Like and comment on posts.
- View your own content.
- Profile page where users can view and edit their profiles.

## Requirements
- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+
- Firebase iOS SDK

## Setup
To run this project, you will need to set up Firebase for your project:

1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. Add an iOS app to your Firebase project and download the `GoogleService-Info.plist` file.
3. Add the `GoogleService-Info.plist` file to your Xcode project.
4. Install Firebase iOS SDK using Swift Package Manager or CocoaPods (depending on what you prefer).
5. Enable Firebase Authentication, Firestore, and Firebase Storage in the Firebase Console.

### Firebase Setup
- Enable **Email/Password Authentication** in the Firebase Console.
- Set up **Firestore** with appropriate security rules to allow users to upload and view content.
- Set up **Firebase Storage** to store uploaded images.

## Installation
To install the necessary dependencies for this project:

### Swift Package Manager
- In Xcode, go to `File > Swift Packages > Add Package Dependency`.
- Enter the following URL for Firebase:
https://github.com/firebase/firebase-ios-sdk.git

## Usage
1. Clone the repository.
 ```bash
 git clone https://github.com/Qiaochu-Zhang/Social-Content-Sharing-App.git

2. Open the project in Xcode.
 ```bash
cd Social-Content-Sharing-App
open MiniSocialContentSharing.xcodeproj

3. Run the app on your iOS simulator or device.


