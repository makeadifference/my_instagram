//
//  HomeVC.swift
//  simple
//
//  Created by drf on 2017/9/15.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import AVOSCloud


class HomeVC: UICollectionViewController{
    
    // 更新数据
    var refresher : UIRefreshControl?
    var page : Int = 12
    var PuuidArray = [String]()
    var picArray = [AVFile]()
    var panGesture : UIPanGestureRecognizer?
    var followees : Int = 0
    var followers : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        refresher = UIRefreshControl()
        refresher?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collectionView?.addSubview(refresher!)
        AVUser.current()?.follow("59bc8f87fe88c20057554f8f", andCallback: {(success : Bool, error : Error?) in
            if success {
                print("成功关注用户")
            } else {
                print("关注用户失败")
                print(error!.localizedDescription)
            }
        })
        // 接收uploaded消息
        NotificationCenter.default.addObserver(self, selector: #selector(uploaded(notification:)), name: Notification.Name.init(rawValue: "uploaded"), object: nil)
        // 设置视图反弹效果
        self.collectionView?.alwaysBounceVertical = true
        // 不知为何无法显示导航栏项目
        navigationItem.title = AVUser.current()?.username
        // 获取用户帖子
        loadPosts()
        refresh()
        print("帖子数量为:\(picArray.count)")
        // 添加退出按钮
        let quitButton = UIBarButtonItem(title: "退出", style: .plain, target: self , action: #selector(logout))
        navigationItem.rightBarButtonItem = quitButton
        // 会覆盖storyboard的配置
        // Register cell classes
        //self.collectionView!.register(picCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //self.collectionView?.register(HeaderView.self , forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")

        // Do any additional setup after loading the view.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        // 测试反弹效果
        return self.PuuidArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! picCell
        picArray[indexPath.row].getDataInBackground({ (data : Data?, error : Error?) in
            if error == nil {
                cell.postImage.image = UIImage(data: data!)
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
        let file = AVUser.current()?.object(forKey: "ava") as? AVFile
        file?.getDataInBackground({ (data: Data?, error: Error?) in
            if error == nil{
                header.userImageView.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        })
        
        header.postsButton.setTitle(String(self.picArray.count), for: UIControlState.normal)
        header.flweeButton.setTitle(String(self.followers), for: .normal)
        header.flwerButton.setTitle(String(self.followees), for: .normal)
        header.usernameText.text = AVUser.current()?.object(forKey: "username") as? String
        header.userIntroButton.text =  AVUser.current()?.object(forKey: "intro") as? String
        header.userwebButton.text = AVUser.current()?.object(forKey: "web") as? String
        
        
        return header
    }
    
    // MARK: Delegate
   override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    postuuid.append(PuuidArray[indexPath.row])
        let storyboard  = UIStoryboard(name: "Main", bundle: nil)
        let postvc = storyboard.instantiateViewController(withIdentifier: "PostsVC") as! PostsVC
        self.navigationController?.pushViewController(postvc, animated: true)
    }
    
    func refresh(){
        collectionView?.reloadData()
        refresher?.endRefreshing()
    }
    
    // MARK: 从服务器检索数据
    func loadPosts(){
        // 从数据库检索贴子数据
        let postsQuery = AVQuery(className: "Posts")
        postsQuery.whereKey("username", equalTo: AVUser.current()?.username!)
        // 每页限制帖子数目
        postsQuery.findObjectsInBackground({ (objects:[Any]?, error : Error?) in
            if error == nil {
                print("成功获取用户帖子")
                // 第二个参数处于性能考虑,释放空间
                self.PuuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.PuuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    print(object)
                    self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                }
            } else {
                print("获取帖子失败")
                print(error!.localizedDescription)
            }
        })
        
        AVUser.current()?.getFollowees({(objects : [Any]? , error : Error?) in
            if error == nil {
                self.followees = (objects?.count)!
                
                print("关注者数: \(self.followees)")
            } else {
                print(error!.localizedDescription)
            }
        })
        
        AVUser.current()?.getFollowers({(objects : [Any]?, error: Error?) in
            if error == nil {
                self.followers = (objects?.count)!
                print("粉丝数:\(self.followers)")
            } else {
                print(error!.localizedDescription)
            }
            
        })
        
        AVUser.current()?.getFollowersAndFollowees({(objects : [AnyHashable : Any]? , error : Error?) in
            if error == nil {
                // 该如何取值？
            } else {
                print(error!.localizedDescription)
            }
            
        })
        
        
        /*
        
        // 检索粉丝
        let followeruery = AVQuery(className: "_Follower")
        followeruery.whereKey("user", equalTo: AVUser.current()?.objectId)
        followeruery.findObjectsInBackground({(objects : [Any]?, error : Error?) in
            if error == nil{
                self.followers = objects?.count
                print("检索粉丝成功\(self.followers!)")
                self.followers = objects?.count
            } else {
                print(error!.localizedDescription)
                print("检索粉丝失败)")
            }
        })
        
        // 检索关注者
        let followeeQuery = AVQuery(className: "_Followee")
        followeeQuery.whereKey("user", equalTo: (AVUser.current()?.objectId))
        followeruery.findObjectsInBackground({(objects : [Any]?, error : Error?) in
            if error == nil {
                self.followees = objects?.count
                print("检索关注者成功\(self.followees!)")
            } else {
                print("检索关注者失败")
                print(error!.localizedDescription)
            }
        })
 */
 
        // 更新单元格数据
        // 使用缓存提高性能
        self.collectionView?.reloadData()
    }
    
    @IBAction func showPosts(_ sender: Any) {
        if !picArray.isEmpty{
            let index = IndexPath(item: 0, section: 0)
            // 实现界面滚动，吧关注点放在帖子上面
            self.collectionView?.scrollToItem(at: index, at: .top, animated: true)
            print("showPosts")
        }
        
    }
    
    @IBAction func showFollowers(_ sender: Any) {
        let storybaord = UIStoryboard(name: "Main", bundle: nil)
        let followerVC = storybaord.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followerVC.show = "follower"
        // 这里应该使用在线加载还是正向传值？
        self.navigationController?.pushViewController(followerVC , animated: true)
    }
    
    @IBAction func showFollowees(_ sender: Any) {
        let followeeVC = storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followeeVC.show = "followee"
        self.navigationController?.pushViewController(followeeVC, animated: true)
    }
    
    @IBAction func Edit(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editVC = storyboard.instantiateViewController(withIdentifier: "EditVC") as! EditVC
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    // 接收uploaded 成功消息后刷新视图
    func uploaded(notification: Notification){
        print("成功接收消息")
        loadPosts()
    }
    
    // 退出当前用户
    func logout(){
        UserDefaults.standard.removeObject(forKey: "username")
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        self.present(loginVC, animated: true, completion: nil)
    }
}

extension HomeVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 30) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
