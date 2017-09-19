//
//  UploadVC.swift
//  simple
//
//  Created by drf on 2017/9/17.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import AVOSCloud

class UploadVC: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    var originFrame = CGRect()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 获取缩放前的视图
        originFrame = imageView.frame
        self.postButton.isEnabled = false
        self.postButton.backgroundColor = .lightGray
        self.imageView.image = UIImage(named:"scene")
        self.textView.text = ""
        
        // 缩放图片
        let zoomPress = UILongPressGestureRecognizer(target: self, action: #selector(zoomImg))
        zoomPress.minimumPressDuration = 1
        self.imageView.addGestureRecognizer(zoomPress)
        self.imageView.isUserInteractionEnabled = true
        // 选择图片
        let picTap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        picTap.numberOfTapsRequired = 1
        // 隐藏键盘
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(hideTap)
        self.imageView.addGestureRecognizer(picTap)
        // 隐藏移除按钮
        self.removeButton.isHidden = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func removeImage(_ sender: Any) {
        self.viewDidLoad()
        
    }
    
    @IBAction func Upload(_ sender: Any) {
        self.view.endEditing(true)
        
        let object = AVObject(className: "Posts")
        object["username"] = AVUser.current()?.username
        object["ava"] = AVUser.current()?.value(forKey: "ava") as! AVFile
        object["puuid"] = "\(String(describing: (AVUser.current()?.username!))) \(NSUUID().uuidString)"
        
        if textView.text.isEmpty {
            object["title"] = ""
        } else {
            // 去掉字符串的空格和换行符,保持内容整洁
            object["title"] = textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            // 示例
            /*
            var str = "Hello, world!"
            let set = CharcterSet(charactersIn : "!@/:;()&")
            str.trimmingCharacters(in : set)
            outpub: "Hello, world"
            */
            // 进行图片格式转换和压缩
            let imageData = UIImageJPEGRepresentation(imageView.image!, 0.5)
            let imageFile = AVFile(name: "post.jpg", data: imageData!)
            object["pic"] = imageFile
            object.saveInBackground({(success:Bool , error:Error?) in
                if error == nil {
                    print("上传贴子成功")
                    // 自定义通知,上传成功刷新主页视图
                    NotificationCenter.default.post(name: Notification.Name.init(rawValue: "uploaded"), object: nil)
                    // 切换Tabbar Controller 为 用户主页
                    self.tabBarController?.selectedIndex = 0
                    self.viewDidLoad()
                } else {
                    print("上传贴子失败")
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
    func selectImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func zoomImg(){
        // 放大后的图片位置
        let zoomed = CGRect(x: 0, y: self.view.center.y - self.view.center.x , width: self.view.frame.width , height: self.view.frame.width)
        // 还原初始位置
        // 这不是我的初始位置！！！
        let unzoomed = originFrame
    
        if imageView.frame == unzoomed {
            UIView.animate(withDuration: 0.3, animations: {
               self.imageView.frame = zoomed
                self.view.backgroundColor = UIColor.black
                self.textView.alpha = 0
                self.postButton.alpha = 0
                self.removeButton.alpha = 0
                self.label.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = UIColor.white
                self.imageView.frame = unzoomed
                self.textView.alpha = 1
                self.postButton.alpha = 1
                self.label.alpha = 1
                self.removeButton.alpha = 1
            })
        }
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }

}

extension UploadVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        self.imageView.image = image
        self.dismiss(animated: true, completion: nil)
        // 允许上传, 必须上传图片,显示移除按钮
        postButton.isEnabled = true
        postButton.backgroundColor = UIColor.blue
        removeButton.isHidden = false
        
    }
}
