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
    
    var imageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoImageView.af_setImage(withURL: imageURL!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
