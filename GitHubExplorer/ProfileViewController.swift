//
//  ProfileViewController.swift
//  GitHubExplorer
//
//  Created by mobileworld on 4/30/20.
//  Copyright © 2020 Felix Cruz. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var joinDateLabel: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var followings: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var id = ""
    var repoData = [JSON]()
    var filteredData = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        id = Globals.profileId
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    override func viewDidAppear(_ animated: Bool) {
        let alertIndicator = UIAlertController(title: "Please Wait...", message: "\n\n", preferredStyle: UIAlertController.Style.alert)
        let activityView = UIActivityIndicatorView(style: .medium)
        activityView.center = CGPoint(x: 139.5, y: 75.5)
        activityView.startAnimating()
        alertIndicator.view.addSubview(activityView)
        present(alertIndicator, animated: true, completion: nil)
        
        let profile = Globals.rootUrl + "users/" + id
        
        Alamofire.request(profile, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: [
        "Authorization":"Basic \(Globals.token)"]).responseJSON { response in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                alertIndicator.dismiss(animated: false, completion: nil)
            })
                switch response.result {
                case .success(_):
                    if let result = response.result.value {
                        let json = JSON(result)
                        print(json)
                        self.profileImageView.sd_setImage(with: URL(string: json["avatar_url"].stringValue), placeholderImage: UIImage(named: "default.png"))
                        self.usernameLabel.text = json["login"].stringValue
                        if json["email"].stringValue == nil || json["email"].stringValue == "null" {
                            self.emailLabel.isHidden = true
                        }
                        else {
                            self.emailLabel.text = json["email"].stringValue
                        }
                        if json["location"].stringValue == nil || json["location"].stringValue == "null" {
                            self.locationLabel.isHidden = true
                        }
                        else {
                            self.locationLabel.text = json["location"].stringValue
                        }
                        if json["bio"].stringValue == nil || json["bio"].stringValue == "null" {
                            self.biographyLabel.isHidden = true
                        }
                        else {
                            self.biographyLabel.text = json["bio"].stringValue
                        }
                        self.joinDateLabel.text = json["created_at"].stringValue
                        self.followers.text = "Followers: \(json["followers"].stringValue)"
                        self.followings.text = "Following: \(json["following"].stringValue)"                        
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }        
        }
        
        let repoUrl = Globals.rootUrl + "users/" + id + "/repos"
        Alamofire.request(repoUrl, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: [
        "Authorization":"Basic \(Globals.token)"]).responseJSON { response in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                alertIndicator.dismiss(animated: false, completion: nil)
            })
                switch response.result {
                case .success(_):
                    if let result = response.result.value {
                        let json = JSON(result)
                        print(json)
                        self.repoData = json.arrayValue
                        self.filteredData = []
                        for i in 0 ..< self.repoData.count {
                            self.filteredData.append(i)
                        }
                        self.tableView.reloadData()
                        
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @objc func dismissKeyboard() {
       view.endEditing(true)
   }
}
extension ProfileViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        self.filteredData = []
        if searchText == "" {
            for i in 0 ..< self.repoData.count {
                self.filteredData.append(i)
            }
        }
        else {
            for i in 0 ..< self.repoData.count {
                if self.repoData[i]["full_name"].stringValue.lowercased().contains(searchText.lowercased()) {
                    self.filteredData.append(i)
                }
            }
        }
        tableView.reloadData()
    }
}
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID:NSString = "repoCell";
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellID as String)!
        cell.selectionStyle = .none
        
        let index = filteredData[indexPath.row]
        let nameLabel = cell.viewWithTag(100) as! UILabel
        nameLabel.text = repoData[index]["full_name"].stringValue
        
        let starLabel = cell.viewWithTag(101) as! UILabel
        starLabel.text = "Star: \(repoData[index]["stargazers_count"].stringValue)"
        
        let forksLabel = cell.viewWithTag(102) as! UILabel
        forksLabel.text = "Forks: \(repoData[index]["forks_count"].stringValue)"
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = filteredData[indexPath.row]
        guard let url = URL(string: repoData[index]["html_url"].stringValue) else { return }
        UIApplication.shared.open(url)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
