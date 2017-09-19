//
//  GuestVC.swift
//  simple
//
//  Created by drf on 2017/9/16.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import AVOSCloud

var guestArray = [AVUser]()
class GuestVC: UICollectionViewController {
    
    // 云端数据
    var puuidArray = [String]()
    var picArray = [AVFile]()
    // 界面对象


/*       注意 ********/
    //var refresher: UIRefreshControl!
    let page : Int = 12
    var backswipe : UISwipeGestureRecognizer!
    var followers : Int = 0
    var followee : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    //    refresher = UIRefreshControl()
     //   refresher.addTarget(self, action: #selector( refresh), for: .valueChanged)
    //  self.view.addSubview(refresher)
        // 允许下拉刷新
        self.collectionView?.alwaysBounceVertical = true
        self.navigationItem.title = guestArray.last?.username
        // 定义返回按钮
        let backbtn = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backbtn
        // 右划返回
        backswipe = UISwipeGestureRecognizer(target: self, action: #selector(back))
        backswipe.direction = .right
        self.view.addGestureRecognizer(backswipe)
        
        loadPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.puuidArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! picCell
        picArray[indexPath.row].getDataInBackground({(data: Data?, error: Error?) in
            if error == nil {
                cell.postImage.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        })
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width:self.view.frame.width, height:240)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        // 下载用户头像
        let infoQuery = AVQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestArray.last?.username!)
        infoQuery.findObjectsInBackground({(objects:[Any]?,error: Error?) in
            if error == nil {
                guard let objects = objects, objects.count > 0 else { return}
                for object in objects {
                    header.usernameText.text = (object as! AVUser).value(forKey: "username") as? String
                    header.userwebButton.text = (object as! AVUser).value(forKey: "web") as? String
                    header.userIntroButton.text = (object as! AVUser).value(forKey: "intro") as? String
                    header.flwerButton.setTitle(String(self.followee), for: .normal)
                    header.flweeButton.setTitle(String(self.followers), for: .normal)
                    header.postsButton.setTitle(String(self.picArray.count), for: .normal)
                    
                    let file = (object as! AVUser).value(forKey: "ava") as! AVFile
                    file.getDataInBackground({(data : Data?,error: Error?) in
                        if error == nil {
                            header.userImageView.image = UIImage(data: data!)
                        } else {
                            print("获取访客头像失败")
                            print(error!.localizedDescription)
                        }
                    })
                }
            } else {
                print("获取访客信息失败")
                print(error!.localizedDescription)
            }
        })
        /*
        let file = AVUser.current()?.object(forKey: "ava") as? AVFile
        file?.getDataInBackground({ (data: Data?, error: Error?) in
            if error == nil{
                header.userImageView.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        })
 */
        
        header.postsButton.setTitle(String(self.picArray.count), for: .normal)
        header.flweeButton.setTitle(String(self.followers), for: .normal)
        header.flwerButton.setTitle(String(self.followee), for: .normal)
        header.postsButton.setTitle(String(self.picArray.count), for: UIControlState.normal)
        header.usernameText.text = AVUser.current()?.object(forKey: "username") as? String
        header.userIntroButton.text =  AVUser.current()?.object(forKey: "intro") as? String
        header.userwebButton.text = AVUser.current()?.object(forKey: "web") as? String
        // 访客与用户之间的关系
        let followeeQuery = AVUser.current()?.followeeQuery()
        followeeQuery?.whereKey("user", equalTo: AVUser.current())
        followeeQuery?.whereKey("followee", equalTo: guestArray.last)
        followeeQuery?.countObjectsInBackground({(count : Int , error:Error?) in
            guard error == nil else { print(error!.localizedDescription); return}
            if count == 0 {
                header.editButton.setTitle("关注", for: .normal)
            } else {
                header.editButton.setTitle("已关注", for: .normal)
                header.editButton.backgroundColor = .lightGray
            }
        })
        
        
        return header
    }
    
    
    
    
    // MARK: my functions
    
    func back(){
        self.navigationController?.popViewController(animated: true)
        if !guestArray.isEmpty {
            guestArray.removeLast()
        }
    }
    
    func refresh(){
        self.collectionView?.reloadData()
    //    self.refresher.endRefreshing()
    }
    
    func loadPosts(){
        // 具有权限问题
        let query = AVQuery(className: "_Posts")
        query.whereKey("username", equalTo: guestArray.last?.username)
        query.limit = page
        query.findObjectsInBackground({(objects:[Any]?, error : Error?) in
            if error == nil {
                self.puuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                   

                }
                self.collectionView?.reloadData()
            }else{
                print(error!.localizedDescription)
            }
        })
        
        // 获取关注的人数
        
        AVUser.current()?.getFollowees({(objects : [Any]? , error : Error?) in
            if error == nil {
                self.followee = (objects?.count)!
                print("关注者数: \(self.followee)")
            } else {
                print(error!.localizedDescription)
            }
        })
        
        // 获取粉丝数
        AVUser.current()?.getFollowers({(objects : [Any]?, error: Error?) in
            if error == nil {
                self.followers = (objects?.count)!
                print("粉丝数:\(self.followers)")
            } else {
                print(error!.localizedDescription)
            }
            
        })
        
        // 注意，因为在后台线程处理，所以要更新数据
        self.collectionView?.reloadData()
    }

}
