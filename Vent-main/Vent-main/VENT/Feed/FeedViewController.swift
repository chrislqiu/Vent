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


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
    }
    
    // Shows updated posts in the feed
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      self.posts.removeAll()
      
      let postsRef = Firestore.firestore().collection("posts")
      postsRef.limit(to: 20).getDocuments { querySnapshot,
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
            print("cant get the user rn")
            return
        }
        let userDataRef = Firestore.firestore().collection("user_data")
        userDataRef.document(userUID).getDocument { docSnapshot, error in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            if let doc = docSnapshot, doc.exists, let data = doc.data(), let asDate = (data["postdate"] as? Timestamp)?.dateValue() {
                self.lastPostedAt = asDate
                print(self.lastPostedAt)
            }
            
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //queryPosts()
    }

   /* private func queryPosts(completion: (() -> Void)? = nil) {

                           
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])

        // Find and return posts that meet query criteria (async)
        query.find { [weak self] result in
            switch result {
            case .success(let posts):
                // Update the local posts property with fetched posts
                self?.posts = posts
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }

            completion?()
        }
    } */

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
        /* queryPosts { [weak self] in
            self?.refreshControl.endRefreshing()
        } */
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:
                   Int) -> Int {
      return self.posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
      -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
      let post = self.posts[indexPath.row]
        cell.configure(with: post, lastPostedAt: self.lastPostedAt)
      return cell
    }
}

extension FeedViewController: UITableViewDelegate { }
