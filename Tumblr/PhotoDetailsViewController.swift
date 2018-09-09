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

}
