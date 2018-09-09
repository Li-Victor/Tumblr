//
//  FullScreenPhotoViewController.swift
//  Tumblr
//
//  Created by Victor Li on 9/9/18.
//  Copyright © 2018 Victor Li. All rights reserved.
//

import UIKit
import Alamofire

class FullScreenPhotoViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var fullScreenImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    var post: Post?

    @IBAction func closeImage(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        if let post = post {
            let photoURL = URL(string: post.photoPath)!
            fullScreenImage.af_setImage(withURL: photoURL, completion: {
                (response) in
                self.scrollView.contentSize = self.fullScreenImage.image!.size
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return fullScreenImage
    }
}
