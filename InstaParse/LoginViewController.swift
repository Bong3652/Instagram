//
//  ViewController.swift
//  InstaParse
//
//  Created by APPLE on 2/11/19.
//  Copyright © 2019 Bong. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func didSignIn(_ sender: UIButton) {
        PFUser.logInWithUsername(inBackground: userNameField.text!, password: passwordField.text!) { (user, error) in
            if user != nil {
                self.performSegue(withIdentifier: "LoginSegue", sender: nil)
            } else {
                print(error as Any)
            }
        }
    }
    
    @IBAction func didSignUp(_ sender: UIButton) {
        let user = PFUser()
        user.username = userNameField.text
        user.password = passwordField.text
        
        user.signUpInBackground { (success, error) in
            if success {
                self.performSegue(withIdentifier: "LoginSegue", sender: nil)
            } else {
                print(error as Any)
            }
        }
        
    }
    
}

