//
//  HomeViewController.swift
//  InstaParse
//
//  Created by APPLE on 2/11/19.
//  Copyright © 2019 Bong. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var postTableView: UITableView!
    let commentBar = MessageInputBar()
    var posts = [PFObject]()
    var showCommentBar = false
    var currentPost:PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.keyboardDismissMode = .interactive
        
        commentBar.delegate = self
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        // Do any additional setup after loading the view.
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(hideKeyboard(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPost()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showCommentBar
    }
    
    @objc func hideKeyboard(note: Notification) {
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        let comment = PFObject(className: "comments")
        
        comment["text"] = text
        comment["post"] = currentPost
        comment["owner"] = PFUser.current()

        currentPost.add(comment, forKey: "comments")
        currentPost.saveInBackground { (success, error) in
            if success {
                print("cool")
            } else {
                print(error)
            }
        }
        postTableView.reloadData()

        commentBar.inputTextView.text = nil
        
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comment = (post["comments"] as? [PFObject]) ?? []
        
        return comment.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = postTableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            let user = post["owner"] as! PFUser
            cell.userLabel.text = user.username
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)
            cell.pictureView.af_setImage(withURL: url!)
            return cell
        } else if indexPath.row <= comments.count {
            let cell = postTableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            let comment = comments[indexPath.row - 1]
            let user = comment["owner"] as! PFUser
            cell.nameLabel.text = user.username
            cell.testLabel.text = comment["text"] as! String
            return cell
        } else {
            let cell = postTableView.dequeueReusableCell(withIdentifier: "AddCommentCell", for: indexPath)
            return cell
        }
        
    }
    
//    func getUser() {
//        let query = PFQuery(className: "Users")
//        query.includeKey("owner")
//        query.limit = 20
//
//        query.findObjectsInBackground { (posts, error) in
//            if posts != nil {
//                self.posts = posts!
//                print("_____________________________________")
//                print(self.posts)
//                self.postTableView.reloadData()
//            } else {
//                print(error as Any)
//            }
//        }
//    }
    
    func getPost() {
        let query = PFQuery(className: "posts")
        query.includeKeys(["owner", "comments", "comments.owner"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                print("_____________________________________")
                print(self.posts)
                self.postTableView.reloadData()
            } else {
                print(error as Any)
            }
        }
    }
    
    @IBAction func didLogOut(_ sender: UIBarButtonItem) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = loginVC
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        currentPost = post
        //let comment = PFObject(className: "comments")
        
//        comment["text"] = "hello"
//        comment["post"] = post
//        comment["owner"] = PFUser.current()
//
//        post.add(comment, forKey: "comments")
//        post.saveInBackground { (success, error) in
//            if success {
//                print("cool")
//            } else {
//                print(error)
//            }
//        }
        if indexPath.row == comments.count + 1 {
            showCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
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
