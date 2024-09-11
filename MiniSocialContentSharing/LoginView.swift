import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoginMode = true
    // Track login status
    @Binding var isLoggedIn: Bool

    var body: some View {
        if isLoggedIn {
            // After user logs in, show the content upload interface
            ContentUploadView()
        } else {
            // Show login/signup interface
            VStack {
                Text(isLoginMode ? "Login" : "Sign Up")
                    .font(.largeTitle)
                    .padding()

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    if isLoginMode {
                        loginUser(email: email, password: password)
                    } else {
                        createUser(email: email, password: password)
                    }
                }) {
                    Text(isLoginMode ? "Login" : "Sign Up")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()

                Button(action: {
                    isLoginMode.toggle()
                }) {
                    Text(isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Login")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
    }

    func loginUser(email: String, password: String) {
        print("Login button pressed with email: \(email) and password: \(password)")
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                // Get detailed error information
                print("Error code: \(error.code)")
                print("Error description: \(error.localizedDescription)")
                print("User Info: \(error.userInfo)")
            } else {
                print("User logged in!")
                isLoggedIn = true  // Switch to upload page after successful login
            }
        }
    }

    func createUser(email: String, password: String) {
        print("Register button pressed with email: \(email) and password: \(password)")
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("User signed up!")
                isLoggedIn = true  // Switch to upload page after successful signup
            }
        }
    }
}
