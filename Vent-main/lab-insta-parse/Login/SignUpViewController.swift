//
//  SignUpViewController.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/1/22.
//

import UIKit

// TODO: Pt 1 - Import Parse Swift
import ParseSwift
import PhotosUI


class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    @IBOutlet weak var signupImage: UIImageView!
    
    
    
    /*private func updateUI() {
            titleLabel.text = task.title
            descriptionLabel.text = task.description

            let completedImage = UIImage(systemName: task.isComplete ? "circle.inset.filled" : "circle")

            completedImageView.image = completedImage?.withRenderingMode(.alwaysTemplate)
            completedLabel.text = task.isComplete ? "Complete" : "Incomplete"

            let color: UIColor = task.isComplete ? .tintColor : .tertiaryLabel
            completedImageView.tintColor = color
            completedLabel.textColor = color

            mapView.isHidden = !task.isComplete
            attachPhotoButton.isHidden = task.isComplete
        }*/
    
  /*  @IBAction func didTapAttachPhotoButton(_ sender: Any) {
        

            if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                    switch status {
                    case .authorized:

                        DispatchQueue.main.async {
                            self?.presentImagePicker()
                        }
                    default:
                        DispatchQueue.main.async {
                            self?.presentGoToSettingsAlert()
                        }
                    }
                }
            } else {
                presentImagePicker()
            }
        }

        private func presentImagePicker() {
            var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())

            config.filter = .images

     
            config.preferredAssetRepresentationMode = .current

            config.selectionLimit = 1

            let picker = PHPickerViewController(configuration: config)


            picker.delegate = self


            present(picker, animated: true)

        } */
    
    
    @IBAction func didClickHere(_ sender: UITapGestureRecognizer) {
        print("did clcik")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupImage.layer.borderWidth = 0
        signupImage.layer.masksToBounds = false
        signupImage.layer.borderColor = UIColor.black.cgColor
        signupImage.layer.cornerRadius = signupImage.frame.height/2
        signupImage.clipsToBounds = true
        
        

    }
     
    
    
    @IBAction func onSignUpTapped(_ sender: Any) {

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

        // TODO: Pt 1 - Parse user sign up
        var newUser = User()
        newUser.username = username
        newUser.email = email
        newUser.password = password

        newUser.signup { [weak self] result in

            switch result {
            case .success(let user):

                print("✅ Successfully signed up user \(user)")

                // Post a notification that the user has successfully signed up.
                NotificationCenter.default.post(name: Notification.Name("login"), object: nil)

            case .failure(let error):
                // Failed sign up
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
/*
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
        

        let result = results.first
        

        guard let assetId = result?.assetIdentifier,
              let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location else {
            return
        }
        
        print("📍 Image location coordinate: \(location.coordinate)")
        

        guard let provider = result?.itemProvider,

              provider.canLoadObject(ofClass: UIImage.self) else { return }
        

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            

            if let error = error {
                DispatchQueue.main.async { [weak self] in self?.showAlert(for:error) }
                
            }
            

            guard let image = object as? UIImage else { return }
            

            
      
            DispatchQueue.main.async { [weak self] in
                
  
                //self?.task.set(image, with: location)
                

                //self?.updateUI()
                
    
                //self?.updateMapView()
            }
        }
    }
} */
