//
//  LoginViewController.swift
//

import UIKit


import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onLoginTapped(_ sender: Any) {

        // Make sure all fields are non-nil and non-empty.
        guard let username = usernameField.text,
              let password = passwordField.text,
              !username.isEmpty,
              !password.isEmpty else {

            showMissingFieldsAlert()
            return
        }
        
        Firebase.Auth.auth().signIn(withEmail: username, password: password) { result, error in
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
        }

    }

    private func showMissingFieldsAlert() {
        let alertController = UIAlertController(title: "Opps...", message: "We need all fields filled out in order to log you in.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

