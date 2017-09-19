//
//  PostsVC.swift
//  simple
//
//  Created by drf on 2017/9/17.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import AVOSCloud

var postuuid = [String]()
class PostsVC: UITableViewController {

    // 从服务器获取的数据
    var avaArray = [AVFile]()
    var usernameArray = [String]()
    var dateArray = [Date]()
    var picArray = [AVFile]()
    var puuidArray = [String]()
    var titleArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // 增加手势控制
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(hideTap)
        // 动态计算单元格高度
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 450
        // 接收通知
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name.init(rawValue: "liked"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name.init(rawValue: "unliked"), object: nil)
        // 从服务器检索数据
        let query = AVQuery(className: "Posts")
        query.whereKey("puuid", equalTo: postuuid.last!)
        query.findObjectsInBackground({(objects: [Any]?,error:Error?) in
            if error == nil {
            self.avaArray.removeAll(keepingCapacity: false)
            self.usernameArray.removeAll(keepingCapacity: false)
            self.dateArray.removeAll(keepingCapacity: false)
            self.picArray.removeAll(keepingCapacity: false)
            self.puuidArray.removeAll(keepingCapacity: false)
            self.titleArray.removeAll(keepingCapacity: false)
            print("正在查询:\(postuuid.last!)")
                
            for object in objects! {
                self.avaArray.append((object as AnyObject).value(forKey:"ava") as! AVFile)
                self.usernameArray.append((object as AnyObject).value(forKeyPath: "username") as! String)
                // 注意这里
                self.dateArray.append((object as AnyObject).createdAt!!)
                self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                self.titleArray.append((object as AnyObject).value(forKey: "title") as! String)
            }
            } else {
                print("查询\(postuuid.last!)失败\(error!.localizedDescription)")
            }
            // 关键
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! postCell
        cell.mydelegate = self
        // Config the cell
        picArray.last?.getDataInBackground({(data:Data?, error:Error?) in
            if error == nil {
                cell.puuidLabel.isHidden = true
                cell.puuidLabel.text = self.puuidArray[indexPath.row]
                // z注意这是在后台线程执行的
                print("puuid是\(self.puuidArray[indexPath.row])")
                print("puuidlabel.text\(cell.puuidLabel.text!)")
                cell.postImageView.image = UIImage(data: data!)
                cell.usernameButton.setTitle(AVUser.current()?.username!, for: .normal)
                cell.usernameButton.sizeToFit()
                cell.textView.text = self.titleArray[indexPath.row]
                cell.textLabel?.sizeToFit()
                /*
                 统计点赞次数
                //if likeCount == 0 {
                cell.likeButton.setTitle("赞", for: .normal)
            } else {
                cell.likeButton.setTitle("赞(\(likecount))", for: .normal)
            }
            */
                self.avaArray[indexPath.row].getDataInBackground({(data : Data?, error : Error?) in
                    if error == nil {
                        cell.userImageView.image = UIImage(data: data!)
                    }else {
                        print("获取用户头像失败\(error!.localizedDescription)")
                    }
                })
            }
    })
        
        // 计算时间差,这些线程真的不能以常规方式思考呀
        if (!self.dateArray.isEmpty){
        let from = dateArray[indexPath.row]
        let now = Date()
        // 时间信息封装类
        let components : Set<Calendar.Component> = [.second, .minute,.hour,.day, . weekOfMonth]
        let differences = Calendar.current.dateComponents(components, from: from, to: now)
        
        if differences.second! <= 0 {
            cell.timeLabel.text = "现在"
        }
        if differences.second! > 0 && differences.minute! <= 0 {
            cell.timeLabel.text = "\(differences.second!)秒"
        }
        if differences.minute! > 0 && differences.hour! <= 0 {
            cell.timeLabel.text = "\(differences.minute!)分钟"
        }
        if differences.hour! > 0 && differences.day! <= 0 {
            cell.timeLabel.text = "\(differences.hour!)小时"
        }
        if differences.day! > 0 && differences.weekOfMonth! <= 0 {
            cell.timeLabel.text = "\(differences.day!)天"
        }
        if differences.weekOfMonth! > 0 {
            cell.timeLabel.text = "\(differences.weekOfMonth!)星期"
        }
        }
        // 点赞功能的实现
        
        if !(cell.puuidLabel.text?.isEmpty)! {
        let didLike = AVQuery(className: "Likes")
        didLike.whereKey("by", equalTo: AVUser.current()?.username!)
        print("by:\(AVUser.current()!.username!)")
        didLike.whereKey("to", equalTo: cell.puuidLabel.text!)
        print("to:\(cell.puuidLabel.text!)")
        // 理解下面这段代码
        didLike.countObjectsInBackground({(count : Int, error : Error?) in
            if count == 0 {
                cell.likeButton.setTitle("like", for: .normal)
                //cell.likeButton.setBackgroundImage(UIImage(named : "unlike"), for: .normal)
            } else {
                cell.likeButton.setTitle("unlike", for: .normal)
                //cell.likeButton.setBackgroundImage(UIImage(named : "like"), for: .normal)
            }
    })
            // 显示赞次数
        let countLikes = AVQuery(className: "Likes")
        countLikes.whereKey("to", equalTo: cell.puuidLabel.text!)
        countLikes.countObjectsInBackground({(count : Int, error : Error?) in
            if count == 0 {
                cell.likeCountLabel.text = ""
            } else if count <= 99 {
        cell.likeCountLabel.text = "(\(count))"
            } else{
        cell.likeCountLabel.text = "((99+))"
            }
        })
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  450
    }

    // MARK: Actions
    
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    func refresh(){
        self.tableView.reloadData()
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PostsVC : presentVC {
    func presentViewController(vc: UIViewController) {
        self.present(vc, animated: true, completion: nil)
    }
    
    
}

