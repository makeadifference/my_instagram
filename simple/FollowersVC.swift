//
//  FollowersVC.swift
//  simple
//
//  Created by drf on 2017/9/16.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import AVOSCloud

class FollowersVC: UITableViewController {
    
    var followerarray  = [AVUser]()
    var show = ""
    var user  =  String()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("number creating")
        if(show == "follower"){
            loadFollowerData()
        } else {
            loadFolloweeData()
        }
        print("test: \(followerarray.count)")
        // 设置标题栏
        navigationItem.title = show
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cell = tableView.dequeueReusableCell(withIdentifier: "followCell") as! followCell
        if cell.userName.text == AVUser.current()?.username {
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(homeVC, animated: true)
        } else {
        let guestVC = storyboard.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            self.navigationController?.pushViewController(guestVC, animated: true)
        }
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("number of cells")
        return followerarray.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followCell", for: indexPath) as! followCell
        cell.userName.text = followerarray[indexPath.row].username
        let ava = followerarray[indexPath.row].object(forKey: "ava") as! AVFile
        // 后台下载用户图片
        ava.getDataInBackground({(data :Data?, error: Error?) in
            if error == nil {
                cell.userImage.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        })
        
        // 设置关注按钮
        let query = followerarray[indexPath.row].followeeQuery()
        query.whereKey("user", equalTo: AVUser.current()!)
        query.whereKey("followee", equalTo: followerarray[indexPath.row])
        query.countObjectsInBackground({(count : Int,error : Error?) in
            if error == nil {
                if count == 0 {
                    cell.followButton.setTitle("关注", for: .normal)
                } else {
                    cell.followButton.setTitle("已关注", for: .normal)
                    cell.followButton.backgroundColor = .lightGray
                }
            }
        })
        
        // 避免关注自身的bug
        if cell.userName.text == AVUser.current()?.username {
            cell.followButton.isHidden = true
        }
        cell.user = self.followerarray[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func loadFollowerData(){
        
        AVUser.current()?.getFollowees({(objects : [Any]? , error : Error?) in
            if error == nil {
                // 线程不安全的，会被修改
                self.followerarray = (objects! as! [AVUser])
                self.tableView.reloadData()
                print(self.followerarray)
                print("num:\(self.followerarray.count)")
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    func loadFolloweeData(){
 
        AVUser.current()?.getFollowers({(objects : [Any]?, error : Error?) in
            if error == nil {
                self.followerarray  = objects as! [AVUser]
                self.tableView.reloadData()
                print(self.followerarray)
                print("num:\(self.followerarray.count)")
            } else {
                print(error!.localizedDescription)
            }
        })
    }

  
}
    
