//
//  LoginViewController.swift
//

import UIKit


import Firebase
import FirebaseCore

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var logInError: UILabel!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        logInError.text = ""
    }
    
    @IBAction func onLoginTapped(_ sender: Any) {

        self.logInError.text = ""
        // Make sure all fields are non-nil and non-empty.
        guard let username = usernameField.text,
              let password = passwordField.text,
              !username.isEmpty,
              !password.isEmpty else {

            showMissingFieldsAlert()
            return
        }
        
        /*Firebase.Auth.auth().signIn(withEmail: username, password: password) { result, error in
            if let e = error {
                
                print(e.localizedDescription)
                
                return
            }
            
            guard let res = result else {
                print("Error occured with logging in")
                return
            }
            
            print("Signed in as \(res.user.email)")
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }*/
        
        Firebase.Auth.auth().signIn(withEmail: username, password: password) { result, error in
            if error != nil {
                print("error with username/password")
                self.logInError.text = "Invalid Username and/or Password"
                self.logInError.textColor = UIColor.red
                return
            }
            
            guard result != nil else {
                print("error with login res")
                return
            }
            
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
            
        }
        
        

    }

    private func showMissingFieldsAlert() {
        let alertController = UIAlertController(title: "Opps...", message: "We need all fields filled out in order to log you in.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

