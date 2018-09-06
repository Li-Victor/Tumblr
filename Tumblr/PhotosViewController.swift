//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Victor Li on 8/29/18.
//  Copyright © 2018 Victor Li. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var posts: [[String: Any]] = []

    @IBOutlet weak var photoTableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoTableView.delegate = self
        photoTableView.dataSource = self

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PhotosViewController.didPullToRefresh(_:)), for: .valueChanged)
        photoTableView.insertSubview(refreshControl, at: 0)
        fetchPhotos()
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        fetchPhotos()
    }
    
    func fetchPhotos() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                self.displayError(error)
            } else if let data = data, let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                // Get the dictionary from the response key
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                self.posts = responseDictionary["posts"] as! [[String: Any]]
                self.photoTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
        task.resume()
    }
    
    func displayError(_ error: Error) {
        let alertController = UIAlertController(title: "Cannot Get Photos", message: error.localizedDescription, preferredStyle: .alert)
        
        let TryAgainAction = UIAlertAction(title: "Try Again", style: .default) { (action) in
            self.fetchPhotos()
        }
        
        alertController.addAction(TryAgainAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let post = self.posts[indexPath.row]
        
        if let photos = post["photos"] as? [[String: Any]] {
            let photo = photos[0]
            let originalSize = photo["original_size"] as! [String: Any]
            let urlString = originalSize["url"] as! String
            let url = URL(string: urlString)
            cell.photoImageView.af_setImage(withURL: url!)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = photoTableView.indexPath(for: cell) {
            
            let post = posts[indexPath.row]
            
            if let photos = post["photos"] as? [[String: Any]] {
                let photo = photos[0]
                let originalSize = photo["original_size"] as! [String: Any]
                let postImageURLString = originalSize["url"] as! String
                let postImageURL = URL(string: postImageURLString)
                
                let photoDetailsViewController = segue.destination as! PhotoDetailsViewController
                photoDetailsViewController.imageURL = postImageURL
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
