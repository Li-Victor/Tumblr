//
//  PhotoDetailsViewController.swift
//  Tumblr
//
//  Created by Victor Li on 9/5/18.
//  Copyright © 2018 Victor Li. All rights reserved.
//

import UIKit
import Alamofire

class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBAction func didTapImage(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "SegueToFullScreenImage", sender: nil)
    }
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let post = post {
            let photoURL = URL(string: post.photoPath)!
            photoImageView.af_setImage(withURL: photoURL)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let fullScreenPhotoViewController = segue.destination as! FullScreenPhotoViewController
        fullScreenPhotoViewController.post = post
    }

}
