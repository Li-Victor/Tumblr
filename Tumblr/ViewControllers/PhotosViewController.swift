//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Victor Li on 8/29/18.
//  Copyright © 2018 Victor Li. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftyJSON

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    var posts: [Post] = []

    @IBOutlet weak var photoTableView: UITableView!
    var refreshControl: UIRefreshControl!
    var isMoreDataLoading = false
    var loadingMorePosts: InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoTableView.delegate = self
        photoTableView.dataSource = self

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PhotosViewController.didPullToRefresh(_:)), for: .valueChanged)
        photoTableView.insertSubview(refreshControl, at: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: photoTableView.contentSize.height, width: photoTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMorePosts = InfiniteScrollActivityView(frame: frame)
        loadingMorePosts!.isHidden = true
        photoTableView.addSubview(loadingMorePosts!)
        
        var insets = photoTableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        photoTableView.contentInset = insets
        
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
            } else if let data = data {
                
                self.posts = JSON(data)["response", "posts"].arrayValue.map {
                    let photoPath = $0["photos", 0, "original_size", "url"].stringValue
                    let date = $0["date"].stringValue
                    return Post(photoPath: photoPath, date: date)
                }
    
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let post = self.posts[indexPath.section]
        
        let url = URL(string: post.photoPath)!
        cell.photoImageView.af_setImage(withURL: url)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // Set the avatar
        profileView.af_setImage(withURL: URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")!)
        headerView.addSubview(profileView)
        
        let post = self.posts[section]
        let postLabel = UILabel(frame: CGRect(x: 50, y: 10, width: 270, height: 30))
        postLabel.text = post.date
        headerView.addSubview(postLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = photoTableView.indexPath(for: cell) {
            
            let post = posts[indexPath.section]
            let photoDetailsViewController = segue.destination as! PhotoDetailsViewController
            photoDetailsViewController.post = post
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func loadMorePosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&offset=\(posts.count + 1)&limit=5")!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let task = session.dataTask(with: url) { (data, response, error) in
            self.isMoreDataLoading = false
            
            if let error = error {
                print(error.localizedDescription)
                self.displayError(error)
            } else if let data = data {
                
                let newPosts: [Post] = JSON(data)["response", "posts"].arrayValue.map {
                    let photoPath = $0["photos", 0, "original_size", "url"].stringValue
                    let date = $0["date"].stringValue
                    return Post(photoPath: photoPath, date: date)
                }
                
                self.posts += newPosts
                
                 self.loadingMorePosts!.stopAnimating()
                
                self.photoTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
        task.resume()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = photoTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - photoTableView.bounds.size.height
            
            if (scrollView.contentOffset.y > scrollOffsetThreshold && photoTableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: photoTableView.contentSize.height, width: photoTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMorePosts?.frame = frame
                loadingMorePosts!.startAnimating()
                
                loadMorePosts()
            }
            
        }
    }
}
