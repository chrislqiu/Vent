
import UIKit
import Firebase
import FirebaseStorage

// TODO: Pt 1 - Import Photos UI
import PhotosUI



class PostViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!

    private var pickedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onPickedImageTapped(_ sender: UIBarButtonItem) {
        // TODO: Pt 1 - Present Image picker
        // Create and configure PHPickerViewController

        // Create a configuration object
        var config = PHPickerConfiguration()

        // Set the filter to only show images as options (i.e. no videos, etc.).
        config.filter = .images

        // Request the original file format. Fastest method as it avoids transcoding.
        config.preferredAssetRepresentationMode = .current

        // Only allow 1 image to be selected at a time.
        config.selectionLimit = 1

        // Instantiate a picker, passing in the configuration.
        let picker = PHPickerViewController(configuration: config)

        // Set the picker delegate so we can receive whatever image the user picks.
        picker.delegate = self

        // Present the picker
        present(picker, animated: true)
    }

    @IBAction func onShareTapped(_ sender: Any) {
        // Dismiss Keyboard
        view.endEditing(true)
        
        // TODO: FIREBASE POSTVIEW
        guard let imageData = previewImageView.image?.pngData() else {
            print("remember to get rid fo this to replace with pfp later")
            return
        }
        
        let storageRef = FirebaseStorage.Storage.storage().reference()
        guard let userUID = Firebase.Auth.auth().currentUser?.uid else {
            print("cant get current user")
            return
        }
        
        let fileRef = storageRef.child("\(userUID)/\(Date().timeIntervalSince1970.formatted()).png")
        
        let uploadTask = fileRef.putData(imageData, metadata: nil) {metadata, error in
            guard metadata != nil else { return }
            if let e = error {
                print(e.localizedDescription)
                return
            }
            
            fileRef.downloadURL { url, error in
                if let e = error {
                    print(e.localizedDescription)
                    return
                }
                
                guard let u = url else {
                    print("Unable to get photo url")
                    return
                }
                var post:[String:Any] = [String:Any]()
                post["textpost"] = self.captionTextField.text
                post["profilepic: "] = u.absoluteString
                
                guard let username = Firebase.Auth.auth().currentUser?.email else {
                    print("cannot set author of post")
                    return
                }
                
                post["author"] = username[..<(username.firstIndex(of:"@") ?? username.endIndex)]
                post["authorUID"] = "\(userUID)"
                
                let postID = "\(userUID)-post\(Date().timeIntervalSince1970.formatted())"
                
                let db = Firestore.firestore()
                db.collection("posts").document(postID).setData(post) { error in
                    if let e = error {
                        print(e.localizedDescription)
                        return
                    }
                }
                print("Post successfully written!")
                self.navigationController?.popViewController(animated: true)
            }
        }
    

    }


    @IBAction func onViewTapped(_ sender: Any) {
        // Dismiss keyboard
        view.endEditing(true)
    }
}


extension PostViewController: PHPickerViewControllerDelegate {

    // PHPickerViewController required delegate method.
    // Returns PHPicker result containing picked image data.
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        // Dismiss the picker
        picker.dismiss(animated: true)

        // Make sure we have a non-nil item provider
        guard let provider = results.first?.itemProvider,
              // Make sure the provider can load a UIImage
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        // Load a UIImage from the provider
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

            // Make sure we can cast the returned object to a UIImage
            guard let image = object as? UIImage else {
                self?.showAlert()
                return
            }

            // Check for and handle any errors
            if let error = error {
                self?.showAlert(description: error.localizedDescription)
                return
            } else {

                // UI updates (like setting image on image view) should be done on main thread
                DispatchQueue.main.async {

                    // Set image on preview image view
                    self?.previewImageView.image = image

                    // Set image to use when saving post
                    self?.pickedImage = image
                }
            }
        }
    }
}

// TODO: Pt 2 - Add UIImagePickerControllerDelegate + UINavigationControllerDelegate
