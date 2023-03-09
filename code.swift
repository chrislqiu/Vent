/*
-Add a table view to the FeedViewController in the storyboard, and add an outlet for it called “postsTableView”
to the FeedViewController file.

-Also add a table view cell to your table view in the storyboard. Add UI to this cell by adding an imageView and two
labels (one for the post’s author and the other for the post’s caption). Set the re-use identifier for this cell to “PostCell”.

-Create a cocoa touch class called PostCell that is a subclass of UITableViewCell. Set the “Class property” of your custom cell
in the storyboard to PostCell. Add outlets for the image view and 2 labels called postImageView, postAuthorLabel, and postCaptionLabel.
Add a configure() method in the PostCell class as follows:

*/

func configure(with post: [String:Any]) {
  if let author = post["author"] as? String {
    postAuthorLabel.text = author
  }
  
  if let caption = post["caption"] as? String {
    postCaptionLabel.text = caption 
  }
  //Don't need this since we're not posting images
  if let imageLink = post["image"] as? String,
    let url = URL(string: imageLink) {
      postImageView.af.setImage(withURL: url) 
    }
}

/*
-Back in the FeedViewController file, set the postsTableView delegate and dataSource to self in the viewDidLoad().
This should prompt an error for missing conformance. Hit fix on the errors to auto-import the necessary functions.
You can leave them blank for now.

-Add a posts variable to the FeedViewController as follows:
*/

var posts: [[String:Any]] = [[String:Any]]()

/*
-Add a viewDidAppear() function to the FeedViewController as follows. Putting the code in viewDidAppear() will
trigger a re-fetch of the posts whenever you make a new post.
*/

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
                                       
      self.posts.append(document.data())
  }                                   
}

/*
-Let’s now finish writing the tableView required functions. Your numberOfRows() function should just return
the count of self.posts. Your cellForRowAt() function should look like this:
*/

func tableView(_ tableView: UITableView, numberOfRowsInSection section:
               Int) -> Int {
  return self.posts.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
  -> UITableViewCell {
  let cell = postsTableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
    
  let post = self.posts[indexPath.row]
  cell.configure(with: post)
  return cell
}

/*
-Put code in scene delegate

Then:
-Set the storyboard ID of the Navigation Controller (not the Feed View Controller) in your storyboard to
“FeedNavigationController” so that it matches the code in line 25.
*/

func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
  {
    
  guard let _ = (scene as? UIWindowScene) else {return}
    
  if let currentUser = Firebase.Auth.auth().currentUser {
    print("Signed in as user: \(currentUser.email)")
    let main = UIStoryboard(name: "Main", bundle: nil)
    let feedNavigationController = main.instantiateviewController(withIdentifier: "FeedNavigationController")
    window?.rootViewController = feedNavigationController
  }
}   
 
/*
-Logout button code
*/

@IBAction func logout(_ sender: Any) {
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

//Set the StoryboardID of your LoginViewController to be “LoginViewController” to match line 122 of the code snippet above.

/*

*/
