//
//  postCell.swift
//  simple
//
//  Created by drf on 2017/9/17.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import AVOSCloud

protocol presentVC {
    func presentViewController(vc : UIViewController)
}

class postCell: UITableViewCell {

    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var puuidLabel: UILabel!
    var mydelegate : presentVC!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 圆形图片
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.clipsToBounds = true
        // 初始状态未点赞
        likeButton.setTitleColor(.clear, for: .normal)
        likeButton.setTitle("like", for: .normal)
        likeButton.setBackgroundImage(UIImage(named: "unlike"), for: .normal)
        // 双击收藏手势
        let likeGuesture = UITapGestureRecognizer(target: self, action: #selector(likeTap))
        likeGuesture.numberOfTapsRequired = 2
        postImageView.isUserInteractionEnabled = true
        postImageView.addGestureRecognizer(likeGuesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func like(_ sender: UIButton) {
        let title = sender.title(for: .normal)
        
        if title == "like" {
            print("点赞")
            let object = AVObject(className: "Likes")
            object["by"] = AVUser.current()?.username
            object["to"] = puuidLabel.text!
            object.saveInBackground({(success : Bool , error : Error?) in
                if success {
                    print("点赞成功")
                    self.likeButton.setTitle("unlike", for: .normal)
                    self.likeButton.setBackgroundImage(UIImage(named : "like"), for: .normal)
                    // 如果设置为喜爱，则发送消息给表格视图刷新数据
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "liked"), object: nil)
                } else {
                    print("点赞失败\(error!.localizedDescription)")
                }
            })
        } else{
            // debug
            print("取消赞")
            let query = AVQuery(className: "Likes")
            query.whereKey("by", equalTo: AVUser.current()?.username!)
            query.whereKey("to", equalTo: puuidLabel.text!)
            query.findObjectsInBackground( {(objects : [Any]? , error : Error?) in
                if error == nil {
                for object in objects! {
                    (object as AnyObject).deleteInBackground({(success : Bool , error : Error?) in
                        self.likeButton.setTitle("like", for: .normal)
                        self.likeButton.setBackgroundImage(UIImage(named: "unlike"), for: .normal)
                        print("取消赞成功")
                        // 发送消息更新数据
                        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unliked"), object: nil)
                    })
                    }
                } else {
                    print("点赞失败\(error!.localizedDescription)")
                }
            })
        }
    }
    
    @IBAction func comment(_ sender: Any) {
        
    }
    
    @IBAction func more(_ sender: Any) {
        let menus = UIAlertController(title: "更多", message: "", preferredStyle: .actionSheet)
        let report = UIAlertAction(title: "举报", style: .default, handler: nil)
        let favorite = UIAlertAction(title: "收藏", style: .default, handler: nil)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        menus.addAction(report)
        menus.addAction(favorite)
        menus.addAction(cancel)
        self.mydelegate.presentViewController(vc: menus)
        // 使用协议显示视图
    }
    
    // 一个漂亮的收藏动画
    func likeTap(){
        // 创建一个图形
        let likePic = UIImageView(image: UIImage(named: "like"))
        likePic.frame.size.width = postImageView.frame.width / 1.5
        likePic.frame.size.height = postImageView.frame.height / 1.5
        likePic.center = postImageView.center
        likePic.alpha = 0.8
        self.addSubview(likePic)
        
        UIView.animate(withDuration: 1){
            likePic.alpha = 0
            // 将图片 大小缩小为0.1倍
            likePic.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
        
        let title = likeButton.title(for: .normal)
        if title == "like" {
            print("点赞")
            let object = AVObject(className: "Likes")
            object["by"] = AVUser.current()?.username
            object["to"] = puuidLabel.text!
            object.saveInBackground({(success : Bool , error : Error?) in
                if success {
                    print("点赞成功")
                    self.likeButton.setTitle("unlike", for: .normal)
                    self.likeButton.setBackgroundImage(UIImage(named : "like"), for: .normal)
                    // 如果设置为喜爱，则发送消息给表格视图刷新数据
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "liked"), object: nil)
                } else {
                    print("点赞失败\(error!.localizedDescription)")
                }
            })
        } else{
            // debug
            print("取消赞")
            let query = AVQuery(className: "Likes")
            query.whereKey("by", equalTo: AVUser.current()?.username!)
            query.whereKey("to", equalTo: puuidLabel.text!)
            query.findObjectsInBackground( {(objects : [Any]? , error : Error?) in
                if error == nil {
                    for object in objects! {
                        (object as AnyObject).deleteInBackground({(success : Bool , error : Error?) in
                            self.likeButton.setTitle("like", for: .normal)
                            self.likeButton.setBackgroundImage(UIImage(named: "unlike"), for: .normal)
                            print("取消赞成功")
                            // 发送消息更新数据
                            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unliked"), object: nil)
                        })
                    }
                } else {
                    print("点赞失败\(error!.localizedDescription)")
                }
            })
        }

    }
   
  }
