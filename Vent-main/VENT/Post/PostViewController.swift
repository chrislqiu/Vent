
import UIKit
import Firebase
import FirebaseStorage

// TODO: Pt 1 - Import Photos UI
import PhotosUI
import SwiftUI



class PostViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var captionTextField: UITextField!
    
    @IBOutlet weak var ShockedButton: UIButton!
    @IBOutlet weak var SadButton: UIButton!
    @IBOutlet weak var HappyButton: UIButton!
    @IBOutlet weak var AngryButton: UIButton!
    @IBOutlet weak var TiredButton: UIButton!
    @IBOutlet weak var EnergizedButton: UIButton!
    @IBOutlet weak var NeutralButton: UIButton!
    
    @IBOutlet weak var currentMoodLabel: UILabel!
    private var color: String! = ""
    
    var profileUrl: String! = ""
    
    @IBAction func checkMood(_ sender: UIButton) {
        if sender.tag == 0 {
            color = "yellow"
            currentMoodLabel.text = "Happy"
            currentMoodLabel.textColor = UIColor(red:247/255, green: 203/255, blue:80/255, alpha:1)
            captionTextField.textColor = UIColor(red:247/255, green: 203/255, blue:80/255, alpha:1)
        } else if sender.tag == 1 {
            color = "orange"
            currentMoodLabel.text = "Energized"
            currentMoodLabel.textColor = UIColor.orange
            captionTextField.textColor = UIColor.orange
        } else if sender.tag == 2 {
            color = "green"
            currentMoodLabel.text = "Shocked"
            currentMoodLabel.textColor = UIColor.green
            captionTextField.textColor = UIColor.green
        } else if sender.tag == 3 {
            color = "cyan"
            currentMoodLabel.text = "Neutral"
            currentMoodLabel.textColor = UIColor.cyan
            captionTextField.textColor = UIColor.cyan
        } else if sender.tag == 4 {
            color = "blue"
            currentMoodLabel.text = "Sad"
            currentMoodLabel.textColor = UIColor.blue
            captionTextField.textColor = UIColor.blue
        } else if sender.tag == 5 {
            color = "red"
            currentMoodLabel.text = "Angry"
            currentMoodLabel.textColor = UIColor.red
            captionTextField.textColor = UIColor.red
        } else if sender.tag == 6 {
            color = "purple"
            currentMoodLabel.text = "Tired"
            currentMoodLabel.textColor = UIColor.purple
            captionTextField.textColor = UIColor.purple
        } else {
            print("choose color pls :D D:")
        }
        print(color ?? "no color")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //WAIT TO PRESS SHARE
        guard let userUID = Firebase.Auth.auth().currentUser?.uid else {
            print("cant get the user rn -feedview issue-")
            return
        }
    
        let userData2Ref = Firestore.firestore().collection("users")
               userData2Ref.document(userUID).getDocument { docSnapshot, error in
                   if let e = error {
                       print(e.localizedDescription)
                       return
                   }
                   if let doc = docSnapshot, doc.exists, let data = doc.data(), let pfpurl = (data["pfp"] as? String) {
                       self.profileUrl = pfpurl //URL(string: pfpurl)
                       //self.tableView.reloadData()
                       print("The pfp is \(self.profileUrl)")
                   }
               }
    }

    @IBAction func onPickedImageTapped(_ sender: UIBarButtonItem) {

        var config = PHPickerConfiguration()

        config.filter = .images

        config.preferredAssetRepresentationMode = .current

        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)

        present(picker, animated: true)
    }

    @IBAction func onShareTapped(_ sender: Any) {
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
                
                post["pfp"] = self.profileUrl
         
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
