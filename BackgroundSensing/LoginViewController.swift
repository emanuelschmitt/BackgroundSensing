//
//  LoginViewController.swift
//  BackgroundSensing
//
//  Created by Emanuel Schmitt on 06.06.17.
//  Copyright © 2017 Emanuel Schmitt. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let authenticationService = AuthenticationService.shared
    let networkController = NetworkController.shared
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK: - Actions
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        guard let username = usernameTextField?.text, let password = passwordTextField?.text else {
            // TODO: handle ui alert
            print("no username or password")
            return
        }
        
        let loginCredentials = LoginCredentials(username: username, password: password)

        let _ = networkController.login(with: loginCredentials).then { data -> () in
            if let token = data["token"] as? String, let userId = data["user_id"] as? Int {
                self.authenticationService.authenticate(userId: userId, authToken: token)
                self.performSegue(withIdentifier: "showStartViewController", sender: nil)
            } else {
                self.usernameTextField.backgroundColor = .red
                self.passwordTextField.backgroundColor = .red
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewController()
    }
    
    fileprivate func setupViewController(){
        
    }
}
    

