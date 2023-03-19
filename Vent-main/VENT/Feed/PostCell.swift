//
//  PostCell.swift
//

import UIKit
import Alamofire
import AlamofireImage
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift

class PostCell: UITableViewCell {

    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    // Blur view to blur out "hidden" posts
    @IBOutlet private weak var blurView: UIVisualEffectView!

    private var imageDataRequest: DataRequest?

    func configure(with post: Post) {
        // TODO: Pt 1 - Configure Post Cell

        // Username
        if let user = post.user {
            usernameLabel.text = user.username
        }

        // Image
        if let imageFile = post.imageFile,
           let imageUrl = imageFile.url {

            // Use AlamofireImage helper to fetch remote image from URL
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    // Set image view image with fetched image
                    self?.postImageView.image = image
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                    break
                }
            }
        }

        // Caption
        captionLabel.text = post.caption
        
        /* shows caption if entered */
        // TODO: make this so u cant post an empty caption later once firebase is implemented
          if post.caption == "" {
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
        if let date = post.createdAt {
            dateLabel.text = DateFormatter.postFormatter.string(from: date)
        }

        // TODO: Pt 2 - Show/hide blur view


    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // TODO: Pt 1 - Cancel image data request

        // Reset image view image.
        postImageView.image = nil

        // Cancel image request.
        imageDataRequest?.cancel()
    }
}
