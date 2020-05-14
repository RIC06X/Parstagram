//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Yanjie Xu on 2020/5/14.
//  Copyright © 2020 Yanjie Xu. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var posts = [PFObject]()
    var numOfPosts: Int!
    let inniNumOfPosts: Int = 20
    let incrementPosts: Int = 20

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    let myRefreshhControl = UIRefreshControl()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reFreshPosts()
        myRefreshhControl.addTarget(self, action: #selector(reFreshPosts), for: .valueChanged)
        tableView.refreshControl = myRefreshhControl
        
    }
    
    @objc func reFreshPosts(){
        numOfPosts = inniNumOfPosts
        
        let query = PFQuery(className:"Posts")
        query.includeKey("author")
        query.limit = numOfPosts
        
        query.findObjectsInBackground{(posts, error) in
            if posts != nil {
                //self.posts.removeAll()
                self.posts = posts!
                self.tableView.reloadData()
                self.myRefreshhControl.endRefreshing()
            }else{
                print("Error in Refresh new posts: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func loadMorePosts(){
        numOfPosts = numOfPosts + incrementPosts
        
        let query = PFQuery(className:"Posts")
        query.includeKey("author")
        query.limit = numOfPosts
        
        query.findObjectsInBackground{(posts, error) in
            if posts != nil {
                //self.posts.removeAll()
                self.posts = posts!
                self.tableView.reloadData()
            }else{
                print("Error in Refresh new posts: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = (post["caption"] as! String)
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.postView.af.setImage(withURL: url)
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
