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
import MessageInputBar
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    var posts = [PFObject]()
    var numOfPosts: Int!
    let inniNumOfPosts: Int = 20
    let incrementPosts: Int = 20

    @IBOutlet weak var tableView: UITableView!
    let commentbar = MessageInputBar()
    
    var showsCommentBar = false
    var selectedPost: PFObject!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        tableView.keyboardDismissMode = .interactive
        
        commentbar.inputTextView.placeholder = "Add a comment..."
        commentbar.sendButton.title = "Post"
        commentbar.delegate = self
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHiden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillBeHiden(note: Notification){
        commentbar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView?{
        return commentbar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()

        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            }else{
                print("Failed to save comment")
            }
        }
        tableView.reloadData()
        
        //Clear and dismiss the inputbar
        commentbar.inputTextView.text = nil
        showsCommentBar = false
        commentbar.inputTextView.resignFirstResponder()
        
        
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
        query.includeKeys(["author", "comments", "comments.author"])
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
        query.includeKeys(["author", "comments", "comments.author"])
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
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count+2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
    
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = (post["caption"] as! String)
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
    
            cell.postView.af.setImage(withURL: url)
            return cell
        }else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            cell.commentLable.text = (comment["text"] as? String) ?? ""
            let user = comment["author"] as! PFUser
            cell.nameLable.text = user.username
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        //print("indexPath.row: \(indexPath.row) and comment.count: \(comments.count)")
        if indexPath.row == comments.count + 1{
            //print("Tapped add a comment")
            showsCommentBar = true
            becomeFirstResponder()
            commentbar.inputTextView.becomeFirstResponder()
            selectedPost = post
        }
                
        
    }
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOutInBackground { (error) in
            if let error = error{
                print(error.localizedDescription)
            }else{
                print("Successful logout")
                let main = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
                let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
                sceneDelegate.window?.rootViewController = loginViewController
            }
        }
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
