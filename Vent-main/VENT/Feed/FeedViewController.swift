//
//  FeedViewController.swift
//

import UIKit

import Firebase
import FirebaseStorage

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    // Posts variable
    var posts: [[String:Any]] = [[String:Any]]()
    var lastPostedAt: Date? = nil

    //var profileUrl: URL? = nil
    var profileUrl: String! = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
    }
    
    @IBAction func postButtonPressed(_ sender: UIBarButtonItem) {
        print("in postButtonPressed")
        guard let userUID = Firebase.Auth.auth().currentUser?.uid else {
            print("wahhhh")
            return
        }
        
        let userDataRef = Firestore.firestore().collection("posts")
        userDataRef.document(userUID).getDocument { docSnapshot, error in
            if let e = error {
                print("date flop")
                return
            }
            
            if let doc = docSnapshot, doc.exists, let data = doc.data(), let asDate = (data["date"] as? Timestamp)?.dateValue() {
                self.lastPostedAt = asDate
                print(self.lastPostedAt)
            }
        }
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        if let userLastPostedAt = self.lastPostedAt {
            let diffHours = Calendar.current.dateComponents([.hour], from: userLastPostedAt, to: Date())
            print("\n\n\nDIFF HOURS = ")
            print(diffHours)
            print("\n\n\n\n\n")
            
            /*if diffHours < 0 {
                diffHours = diffHours * -1
            }
            
            if abs(diffHours) < 24 {
                errorPopup(errorTitle: "Already Posted!", errorMessage: "You can only post once a day!")
            } else {
                performSegue(withIdentifier: "sharePostSegue", sender: self)
            }*/
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sharePostSegue" {
            
            
            //errorPopup(errorTitle: "WAHHH", errorMessage: "wahhhh part 2 can't post no time")
            
        }
    }
    
    private func errorPopup(errorTitle: String, errorMessage: String) {
        let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    // Shows updated posts in the feed
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      self.posts.removeAll()
      
      let postsRef = Firestore.firestore().collection("posts")
      postsRef.order(by: "date", descending: true).limit(to: 20).getDocuments { querySnapshot,
          error in
          if let e = error {
            print(e.localizedDescription)
            return
          }
                                           
          guard let results = querySnapshot else {
            print("No results returned!")
            return
          }
                                           
          for document in results.documents {
            self.posts.append(document.data())
          }
 
          self.tableView.reloadData()
      }

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
                       self.tableView.reloadData()
                       print("The pfp is \(self.profileUrl)")
                   }
               }
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }


    @IBAction func onLogOutTapped(_ sender: Any) {
        do {
          try Firebase.Auth.auth().signOut()
        }
        catch {
          print("No user signed in!")
        }
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let delegate = windowScene.delegate as? SceneDelegate else { return }
        
        delegate.window?.rootViewController = loginViewController
    }

    @objc private func onPullToRefresh() {
       refreshControl.beginRefreshing()
        viewDidAppear(true)
        refreshControl.endRefreshing()
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:
                   Int) -> Int {
      return self.posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
      -> UITableViewCell {
          
//          self.posts = self.posts.sorted{(($0["date"] as! String) > ($1["date"] as! String))}
          let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
      let post = self.posts[indexPath.row]
          cell.configure(with: post, lastPostedAt: self.lastPostedAt, profileUrl: post["pfp"] as? String ?? "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.shutterstock.com%2Fsearch%2Fprofile&psig=AOvVaw3h-DdFoyAJ6F-_ywfKYYwd&ust=1680219494030000&source=images&cd=vfe&ved=0CA8QjRxqFwoTCLCCysKngv4CFQAAAAAdAAAAABAE")
      return cell
    }
}

extension FeedViewController: UITableViewDelegate { }
