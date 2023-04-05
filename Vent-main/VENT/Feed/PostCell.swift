//
//  PostCell.swift
//

import UIKit
import Alamofire
import AlamofireImage
import Firebase
import FirebaseStorage
//import FirebaseFirestore

class PostCell: UITableViewCell {

    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    // Blur view to blur out "hidden" posts
    @IBOutlet private weak var blurView: UIVisualEffectView!

    private var imageDataRequest: DataRequest?

    func configure(with post: [String:Any], lastPostedAt: Date?, profileUrl: String?) {
        
        if let user = post["author"] as? String {
          usernameLabel.text = user
        }
        
        if let caption = post["textpost"] as? String {
          captionLabel.text = caption
        }
        
        //print(profileUrl)
        postImageView.af.setImage(withURL: URL(string: profileUrl!)!)
 
      /*  if let userLastPostedAt = lastPostedAt, let postCreationDate = (post["date"] as? Timestamp)?.dateValue(), let diffHours = Calendar.current.dateComponents([.hour], from: postCreationDate, to: userLastPostedAt).hour {
            blurView.isHidden = abs(diffHours) < 24
            print(blurView.isHidden)
        } else {
            blurView.isHidden = false
        } */

        
        /* shows caption if entered */
        // TODO: make this so u cant post an empty caption later once firebase is implemented
        if captionLabel.text == "" {
                captionLabel.layer.masksToBounds = true
                captionLabel.layer.cornerRadius = 8
                captionLabel.backgroundColor = UIColor.init(white: 1, alpha: 0.0)
            } else {
                captionLabel.layer.masksToBounds = true
                captionLabel.layer.cornerRadius = 8
                captionLabel.backgroundColor = UIColor.white.withAlphaComponent(0.7)
                
            }
        
        if let color = post["color"] as? String {
            switch (color) {
            case "yellow":
                captionLabel.textColor = UIColor(red:247/255, green: 203/255, blue:80/255, alpha:1)
            case "orange":
                captionLabel.textColor = UIColor.orange
            case "green":
                captionLabel.textColor = UIColor.green
            case "cyan":
                captionLabel.textColor = UIColor.cyan
            case "blue":
                captionLabel.textColor = UIColor.blue
            case "red":
                captionLabel.textColor = UIColor.red
            case "purple":
                captionLabel.textColor = UIColor.purple
            default:
                captionLabel.textColor = UIColor.black
            }
        }
        
            
            /* circle */
            postImageView.layer.borderWidth = 1
            postImageView.layer.masksToBounds = false
            postImageView.layer.borderColor = UIColor.black.cgColor
            postImageView.layer.cornerRadius = postImageView.frame.height/2
            postImageView.clipsToBounds = true
            /* circle */

        // Date
       /* if let date = post["date"] {
            dateLabel.text = DateFormatter.postFormatter.string(from: date as! Date)
        } */

    }

    override func prepareForReuse() {
        super.prepareForReuse()

        postImageView.image = nil

        imageDataRequest?.cancel()
    }
}
