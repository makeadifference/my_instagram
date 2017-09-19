//
//  followCell.swift
//  simple
//
//  Created by drf on 2017/9/16.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import AVOSCloud

class followCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var followButton: UIButton!
    var user : AVUser?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImage.layer.cornerRadius = userImage.frame.width/2
        userImage.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func follow(_ sender: Any) {
        let title = followButton.title(for: .normal)
       
        
        guard user != nil else {
            print("user 为 nil")
            return
        }
    
        if title == "关注"{
            AVUser.current()?.follow((user?.objectId!)!, andCallback: {(success: Bool,error: Error?)  in
                if success {
                    self.followButton.setTitle("已关注", for: .normal)
                    self.followButton.backgroundColor = .lightGray
                } else {
                    print("关注失败")
                    print(error!.localizedDescription)
                }
            })
        } else{
            AVUser.current()?.unfollow((user?.objectId!)!, andCallback: {(success: Bool, error : Error?) in
                if success {
                    self.followButton.setTitle("关注", for: .normal)
                    self.followButton.backgroundColor = .white
                } else {
                    print(error!.localizedDescription)
                    print("取消关注失败")
                }
            })
        }
        
        
        
        print("调用")
    }

}
