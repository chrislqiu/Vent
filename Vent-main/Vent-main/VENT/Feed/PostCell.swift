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

    func configure(with post: [String:Any], lastPostedAt: Date?) {
        
        if let user = post["author"] as? String {
          usernameLabel.text = user
        }
        
        if let caption = post["caption"] as? String {
          captionLabel.text = caption
        }
          
      if let imageLink = post["image"] as? String,
            let url = URL(string: imageLink) {
            postImageView.af.setImage(withURL: url)
            }
        
        if let userLastPostedAt = lastPostedAt, let postCreationDate = (post["date"] as? Timestamp)?.dateValue(), let diffHours = Calendar.current.dateComponents([.hour], from: postCreationDate, to: userLastPostedAt).hour {
            blurView.isHidden = abs(diffHours) < 24
            print(blurView.isHidden)
        } else {
            blurView.isHidden = false
        }

        
        /* shows caption if entered */
        // TODO: make this so u cant post an empty caption later once firebase is implemented
        if captionLabel.text == "" {
                captionLabel.layer.masksToBounds = true
                captionLabel.layer.cornerRadius = 8
                captionLabel.backgroundColor = UIColor.init(white: 1, alpha: 0.0)
            } else {
                captionLabel.layer.masksToBounds = true
                captionLabel.layer.cornerRadius = 8
                captionLabel.backgroundColor = UIColor.purple.withAlphaComponent(0.7)
            }
            
            /* circle */
            postImageView.layer.borderWidth = 1
            postImageView.layer.masksToBounds = false
            postImageView.layer.borderColor = UIColor.black.cgColor
            postImageView.layer.cornerRadius = postImageView.frame.height/2
            postImageView.clipsToBounds = true
            /* circle */

        // Date
        if let date = post["date"] {
            dateLabel.text = DateFormatter.postFormatter.string(from: date as! Date)
        }

    }

    override func prepareForReuse() {
        super.prepareForReuse()

        postImageView.image = nil

        imageDataRequest?.cancel()
    }
}
