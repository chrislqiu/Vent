//
//  SignUpViewController.swift
//
//

import UIKit

import ParseSwift
import PhotosUI


class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    private var pickedImage: UIImage?

    @IBOutlet weak var signupImage: UIImageView! {
        didSet{
            signupImage.isUserInteractionEnabled = true;
        }
    }
    

    @IBAction func didClickHere(_ sender: UITapGestureRecognizer) {
        print("did click")
       var config = PHPickerConfiguration()

       config.filter = .images

       config.preferredAssetRepresentationMode = .current

       config.selectionLimit = 1

       let picker = PHPickerViewController(configuration: config)

       picker.delegate = self

       present(picker, animated: true)
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupImage.layer.borderWidth = 0
        signupImage.layer.masksToBounds = false
        signupImage.layer.borderColor = UIColor.black.cgColor
        signupImage.layer.cornerRadius = signupImage.frame.height/2
        signupImage.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didClickHere(_:)))

    }
     
    
    
    @IBAction func onSignUpTapped(_ sender: Any) {
        // TODO: add actions to save pfp
        // Make sure all fields are non-nil and non-empty.
        guard let username = usernameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !username.isEmpty,
              !email.isEmpty,
              !password.isEmpty else {

            showMissingFieldsAlert()
            return
        }
// TODO: PROFILE PICTURE TO FIREBASE
        guard let pfp = signupImage.image?.pngData() else {
            print("no image data")
            return
        }
        
        let storageRef = FirebaseStorage.Storage.storage().reference()
        guard let userUID = Firebase.Auth.auth().currentUser?.uid else {
            print("can't get current user")
            return
        }
        
        let fileRef = storageRef.child("\(userUID)/\(Date().timeIntervalSince1970.formatted()).png")

        let uploadTask = fileRef.putData(pfp, metadata: nil) { metadata, error in
            guard metadata != nil else {return }
            if let e = error {
                print(e.localizedDescription)
                return
            }
            
            fileRef.downloadURL { URL, error in
                if let e = error {
                    print(e.localizedDescription)
                    return
                }
                
                
                guard let u = URL else {
                    print("Unable to get photo url")
                    return
                }
                
                var post:[String:Any] = [String: Any]()
               // post["caption"] = self.captionField.text
                post["image"] = u.absoluteString
                
                guard let username = Firebase.Auth.auth().currentUser?.email else {
                    print("Cannot set author of post")
                    return
                }
                
                post["author"] = username[..<(username.firstIndex(of: "@") ?? username.endIndex)]
                post["authorUID"] = "\(userUID)"
                
                let postID = "\(userUID)-post\(Date().timeIntervalSince1970.formatted())"
                
                let db = Firestore.firestore()
                db.collection("posts").document(postID).setData(post) { error in
                    if let e = error {
                        print(e.localizedDescription)
                        return
                    }
                    
                    print("Post successfully written! :)")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        /*  end of profile pic code */
        
 
        var newUser = User()
        newUser.username = username
        newUser.email = email
        newUser.password = password

        newUser.signup { [weak self] result in

            switch result {
            case .success(let user):

                print("✅ Successfully signed up user \(user)")

                NotificationCenter.default.post(name: Notification.Name("login"), object: nil)

            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
        }
    }

    private func showMissingFieldsAlert() {
        let alertController = UIAlertController(title: "Opps...", message: "We need all fields filled out in order to sign you up.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

extension SignUpViewController {

    func presentGoToSettingsAlert() {
        let alertController = UIAlertController (
            title: "Photo Access Required",
            message: "In order to post a photo to complete a task, we need access to your photo library. You can allow access in Settings",
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }

        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    
    private func showAlert(for error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(error?.localizedDescription ?? "Please try again...")",
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
}

extension SignUpViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
        provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

            guard let image = object as? UIImage else {
                //self?.showAlert()
                return
            }


            if let error = error {

                return
            } else {
                DispatchQueue.main.async {

                    self?.signupImage.image = image

                    self?.pickedImage = image
                }
            }
        }
    }
}
