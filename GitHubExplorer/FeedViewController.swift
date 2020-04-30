//
//  ViewController.swift
//  GitHubExplorer
//
//  Created by mobileworld on 4/29/20.
//  Copyright © 2020 Felix Cruz. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class FeedViewController: UIViewController, UISearchBarDelegate {

    var query = ""
    var page = 1
    var since = 1
    var dataArray = [JSON]()
    var countArray:[String:Int] = [:]
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchBar.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        self.indicator.isHidden = false
        loadData()
    }
    func loadData(){
        isLoading = true
        var searchUrl = Globals.rootUrl + "search/users"
        if query != "" {
            searchUrl = "\(searchUrl)?q=\(query)&page=\(page)"
        }
        else {
            searchUrl = "\(Globals.rootUrl)users?since=\(since)"
        }
        Alamofire.request(searchUrl, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: [
            "Authorization":"Basic \(Globals.token)"]).responseJSON { response in
                self.indicator.isHidden = true
                self.isLoading = false
                switch response.result {
                case .success(_):
                    if let result = response.result.value {
                        let json = JSON(result)
                        print(json)
                        if json["items"].arrayValue.count > 0 {
                            self.dataArray.append(contentsOf: json["items"].arrayValue)
                            self.tableView.reloadData()
                        }
                        else if json.arrayValue.count > 0 {
                            self.dataArray.append(contentsOf: json.arrayValue)
                            self.tableView.reloadData()
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
        
        }
    }
    func getRepoCount(id:String, label:UILabel) {
        if countArray[id] != nil {
            label.text = "\(countArray[id]!)"
            return
        }
        label.text = "-"
        let searchUrl = Globals.rootUrl + "users/\(id)"
        Alamofire.request(searchUrl, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: [
        "Authorization":"Basic \(Globals.token)"]).responseJSON { response in
                switch response.result {
                case .success(_):
                    if let result = response.result.value {
                        let json = JSON(result)
                        if let count = json["public_repos"].int {
                            self.countArray[id] = count
                            label.text = "\(count)"
                        }
                        else {
                            label.text = "-"
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    label.text = "-"
                }
        
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        query = searchText
        dataArray = []
        page = 1
        since = 1
        loadData()
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID:NSString = "userCell";
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellID as String)!
        cell.selectionStyle = .none
        
        let imageView = cell.viewWithTag(100) as! UIImageView
        imageView.sd_setImage(with: URL(string: dataArray[indexPath.row]["avatar_url"].stringValue), placeholderImage: UIImage(named: "default.png"))
        let nameLabel = cell.viewWithTag(101) as! UILabel
        nameLabel.text = dataArray[indexPath.row]["login"].stringValue
        
        let countLabel = cell.viewWithTag(102) as! UILabel
        getRepoCount(id: dataArray[indexPath.row]["login"].stringValue, label: countLabel)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Globals.profileId = dataArray[indexPath.row]["login"].stringValue
        performSegue(withIdentifier: "toProfile", sender: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dataArray.count - 1 && !isLoading {
            if query != "" {
                page = page + 1
            }
            else {
                since = dataArray.count + 1
            }
            loadData()
        }
    }
}

