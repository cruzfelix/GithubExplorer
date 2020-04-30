//
//  LoginViewController.swift
//  GitHubExplorer
//
//  Created by mobileworld on 4/30/20.
//  Copyright © 2020 Felix Cruz. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @IBAction func onLogin(_ sender: Any) {
        let alertIndicator = UIAlertController(title: "Please Wait...", message: "\n\n", preferredStyle: UIAlertController.Style.alert)
        let activityView = UIActivityIndicatorView(style: .medium)
        activityView.center = CGPoint(x: 139.5, y: 75.5)
        activityView.startAnimating()
        alertIndicator.view.addSubview(activityView)
        present(alertIndicator, animated: true, completion: nil)
        
        let searchUrl = Globals.rootUrl + "authorizations"
        let username = emailTextField.text!
        let password = passwordTextField.text!
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        Alamofire.request(searchUrl, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: [
        "Authorization":"Basic \(base64LoginString)"]).responseJSON { response in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                alertIndicator.dismiss(animated: false, completion: nil)
            })
                switch response.result {
                case .success(_):
                    if let result = response.result.value {
                        let json = JSON(result)                        
                        if json.arrayValue.count > 0 {
                            Globals.token = base64LoginString
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                self.performSegue(withIdentifier: "toFeed", sender: nil)
                            })
                            return
                        }
                        else {
                            print(json)
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            
            self.alert(message: "Login failure!")
        
        }
    }
    func alert(message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in

            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
