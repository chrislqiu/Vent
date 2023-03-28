
import UIKit
import Firebase
import FirebaseStorage

// TODO: Pt 1 - Import Photos UI
import PhotosUI



class PostViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var captionTextField: UITextField!
    
    private var color: String! = ""
    
    @IBAction func checkMood(_ sender: UIButton) {
        if sender.tag == 0 {
            color = "yellow"
        } else if sender.tag == 1 {
            color = "orange"
        } else if sender.tag == 2 {
            color = "green"
        } else if sender.tag == 3 {
            color = "cyan"
        } else if sender.tag == 4 {
            color = "blue"
        } else if sender.tag == 5 {
            color = "red"
        } else if sender.tag == 6 {
            color = "purple"
        } else {
            print("choose color pls :D D:")
        }
        print(color ?? "no color")
    }
    
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

        // Present the picker
        present(picker, animated: true)
    }

    @IBAction func onShareTapped(_ sender: Any) {
        // Dismiss Keyboard
        view.endEditing(true)
        
        
        let storageRef = FirebaseStorage.Storage.storage().reference()
        guard let userUID = Firebase.Auth.auth().currentUser?.uid else {
            print("cant get current user")
            return
        }
        
        let fileRef = storageRef.child("\(userUID)/\(Date().timeIntervalSince1970.formatted()).png")
        
        let data = Data()
        
        let uploadTask = fileRef.putData(data, metadata: nil) {metadata, error in
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
                
                var post:[String:Any] = [String:Any]()
                post["textpost"] = self.captionTextField.text
                post["date"] = FieldValue.serverTimestamp()
                post["color"] = self.color
                
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
                    print("Post success!")
                    db.collection("user_data").document(userUID).setData([ "postdate": FieldValue.serverTimestamp() ]) { e in
                        if let e = error {
                            print(e.localizedDescription)
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    

    }


    @IBAction func onViewTapped(_ sender: Any) {
        // Dismiss keyboard
        view.endEditing(true)
    }
}




// TODO: Pt 2 - Add UIImagePickerControllerDelegate + UINavigationControllerDelegate
