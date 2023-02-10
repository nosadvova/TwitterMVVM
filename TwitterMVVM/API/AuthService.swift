import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseCore

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let userImage: UIImage
}

struct AuthSevice {
    
    static let shared = AuthSevice()
    
    func logInUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
        
    }

    func registerUser(credentials: AuthCredentials, completion: @escaping (Error?, DatabaseReference) -> ()) {
        
        let email = credentials.email
        let password = credentials.password
        let fullname = credentials.fullname
        let username = credentials.username
        
        guard let imageData = credentials.userImage.jpegData(compressionQuality: 0.3) else {return}
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_PROFILE_IMAGES.child(filename)
        
        storageRef.putData(imageData, metadata: nil) { (meta, error) in
            storageRef.downloadURL { (url, error) in
                guard let userImageUrl = url?.absoluteString else {return}
                
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if let error = error {
                        print("Auth error", error.localizedDescription)
                        return
                    }
                    
                    guard let uid = result?.user.uid else {return}
                    let values = ["userImageUrl": userImageUrl,
                                "email": email,
                                "password": password,
                                "fullName": fullname,
                                "username": username]
                    
                    DB_REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
                }
            }
        }
    }
}

