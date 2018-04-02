//
//  ViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by QuickBlox team
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

import Quickblox
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginBtn: UIButton!
    
    var currentUser: QBUUser?
    var users: [String : String]?
    var emails: [String : String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        QBSettings.applicationID = 0
        QBSettings.authKey = ""
        QBSettings.authSecret = ""
        QBSettings.accountKey = ""
        QBSettings.autoReconnectEnabled = true
        
        // fetching users from Users.plist
        if let path = Bundle.main.path(forResource: "Users", ofType: "plist") {
            users = NSDictionary(contentsOfFile: path) as? [String : String]
        }
        
        precondition(users!.count > 0, "Please add users to Users.plist with format [email:password])")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loginBtn.isHidden = false
    }
    
    //MARK: - Actions
    
    @IBAction func didPressLogin(_ sender: UIButton) {
        presentUsersList()
    }
    
    func presentUsersList() {
        
        let alert = UIAlertController.init(title: "Login as:", message: nil, preferredStyle: .actionSheet)
        
        for (index, user) in users!.enumerated() {
            let user = UIAlertAction.init(title: String(format: "%@%zu", "User ", index + 1), style: .default) { action in
                self.login(email: user.key, password: user.value)
            }
            alert.addAction(user)
        }
        
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { action in
            self.loginBtn.isHidden = false
        }
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
        self.loginBtn.isHidden = true
    }
    
    func login(email: String, password: String) {
        SVProgressHUD.show(withStatus: "Logining to rest")
        QBRequest.logIn(withUserEmail: email, password: password, successBlock:{ r, user in
            self.currentUser = user
            SVProgressHUD.show(withStatus: "Connecting to chat")
            QBChat.instance.connect(with: user) { err in
                let emails = self.users?.keys.filter {$0 != user.email}
                SVProgressHUD.show(withStatus: "Geting users Info")
                QBRequest.users(withEmails: emails!, page:nil, successBlock: { r, p, users in
                    self.performSegue(withIdentifier: "CallViewController", sender:users)
                    SVProgressHUD.dismiss()
                })
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let callVC  = segue.destination as! CallViewController
        callVC.opponets = sender as? [QBUUser]
        callVC.currentUser = self.currentUser
    }
}
