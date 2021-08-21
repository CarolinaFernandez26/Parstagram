//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Carolina Fernandez on 8/13/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    var posts = [PFObject]()
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    @IBOutlet weak var TableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        TableView.delegate = self
        TableView.dataSource = self
        TableView.keyboardDismissMode = .interactive
        
        // Do any additional setup after loading the view.
    }
    
    override var inputAccessoryView: UIView?{ return commentBar}
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    
    override func viewDidAppear( _ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Posts")
        
        query.includeKey("author")
        query.limit = 20
        query.findObjectsInBackground { ( posts, error ) in
            if posts != nil {
                self.posts = posts!
                self.TableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let post = posts[section]
        //[] means whatever is on the left if it is nil, set it to default value ??
        let comments = (post["comments"]as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    func numberOfSections ( in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = TableView.dequeueReusableCell(withIdentifier: "PostCellTableViewCell" ) as! PostCellTableViewCell
            let user = post ["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post ["caption"] as! String
     
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL (string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            
            return cell
        } else if indexPath.row <= comments.count{
            let cell = TableView.dequeueReusableCell(withIdentifier: "CommentCell" ) as! CommentCell
            
            return cell
        }
        else {
            let cell = TableView.dequeueReusableCell(withIdentifier:    "AddCommentCell")!
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //add fake comment
        let post = posts[indexPath.section]
        let comment = PFObject(className:   "Comments" )
        comment["text"] = "This is a random comment"
        comment["post"] = post
        comment["author"] = PFUser.current()!
        
        //every post will have an array called comments and we will add this comment to the array
        post.add(comment, forKey:"comments")
        
        post.saveInBackground{ (success, error) in
            if success {
                print ("Comment saved")
            } else {
                print ("Error Saving comment")
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

    
        func onLogoutButton(_ sender: Any) {
        //clearse Parse cache
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        //one object that exists for each application
        //have to cast into Appdelegate its the only one that has the Window property
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else {return}
        
        delegate.window?.rootViewController = loginViewController
    }
    
    
}
}
