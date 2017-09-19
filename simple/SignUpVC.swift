//
//  SignUpVC.swift
//  simple
//
//  Created by drf on 2017/9/14.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import AVOSCloud

class SignUpVC: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var introText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var websiteText: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cencelButton: UIButton!
    @IBOutlet weak var suButton: UIButton!
    
    var tapGuesture : UITapGestureRecognizer?
    var keyboardHeight = CGRect()
    var scrollViewHeight :CGFloat = 0
    var imgaePicker : UIImagePickerController?
    var imageGuesture : UITapGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 布局
        self.scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scrollViewHeight = self.view.frame.height
        userImage.frame = CGRect(x: self.view.frame.width/2 - 40, y: 40, width: 80, height: 80)
        userIdText.frame = CGRect(x: 20, y: 140, width: self.view.frame.width-40, height: 35)
        passwordText.frame = CGRect(x: 20, y: 195, width: self.view.frame.width-40, height: 35)
        repeatPassword.frame = CGRect(x: 20, y: 250, width: self.view.frame.width-40, height: 35)
        emailText.frame = CGRect(x: 20, y: 305, width: self.view.frame.width-40, height: 35)
        introText.frame = CGRect(x: 20, y: 360, width: self.view.frame.width-40, height: 35)
        nameText.frame = CGRect(x: 20, y: 415, width: self.view.frame.width-40, height: 35)
        websiteText.frame = CGRect(x: 20, y: 470, width: self.view.frame.width-40, height: 35)
        tapGuesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        suButton.frame = CGRect(x: 20, y: 525, width: self.view.frame.width/4, height: 40)
        cencelButton.frame = CGRect(x: self.view.frame.width - 20 - suButton.frame.width, y: 525, width: self.view.frame.width/4, height: 40)
        
        self.view.addGestureRecognizer(tapGuesture!)
        tapGuesture?.numberOfTapsRequired = 1
        // 注意这个属性
        //scrollView.contentSize.height = self.view.frame.height
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        // 圆形用户头像
        userImage.layer.cornerRadius = 40
        userImage.clipsToBounds = true
        // 用户头像选取
        imgaePicker = UIImagePickerController()
        imgaePicker?.sourceType = .photoLibrary
        imgaePicker?.delegate = self
        userImage.isUserInteractionEnabled = true
        imageGuesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        userImage.addGestureRecognizer(imageGuesture!)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func SignUp(_ sender: Any) {
        self.view.endEditing(true)
    }

    @IBAction func Cencel(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification: Notification){
        keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue) as! CGRect
        if(introText.isEditing || nameText.isEditing || websiteText.isEditing || emailText.isEditing){
        UIView.animate(withDuration: 0.4, animations: {
            self.scrollView.frame.origin.y = self.view.frame.origin.y - self.keyboardHeight.height

})
        }
        
    }
    
    func keyboardWillHide(notification: Notification){
        self.scrollView.frame.size.height = self.scrollViewHeight
        if(!((userIdText.text?.isEmpty)! || (passwordText.text?.isEmpty)! || (repeatPassword.text?.isEmpty)!)){
        UIView.animate(withDuration: 0.4, animations: {
            self.scrollView.frame.origin.y += self.keyboardHeight.height
        })
        }
        
    }
    
    func selectImage(){
        self.present(imgaePicker!, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
  
        self.userImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    @IBAction func signUp(_ sender: Any) {
        if((userIdText.text?.isEmpty)! || (passwordText.text?.isEmpty)! || (introText.text?.isEmpty)! || (repeatPassword.text?.isEmpty)! || (nameText.text?.isEmpty)! || (websiteText.text?.isEmpty)!){
            let alertView = UIAlertController(title: "注意", message: "请填写所有信息", preferredStyle: .alert)
            let action = UIAlertAction(title: "请填写所有信息", style: .cancel, handler: nil)
            alertView.addAction(action)
            self.present(alertView, animated: true, completion: nil)
        }
        
        let user =  AVUser()
        user.email = emailText.text
        user.password = passwordText.text
        user.username = userIdText.text
        user["intro"] = introText.text
        user["web"] = websiteText.text
        let avaData = UIImageJPEGRepresentation(userImage.image!, 0.5)
        user["ava"] = AVFile(name: "ava.jpg", data: avaData!)
        user.signUpInBackground({ (success : Bool , error : Error?) in
            if success {
                UserDefaults.standard.set(user.username , forKey:"username")
                UserDefaults.standard.set(user.email,forKey:"email")
                // 这里应该让用户自己选择,实现一个复选框
                UserDefaults.standard.set(user.password ,forKey:"password")
                UserDefaults.standard.synchronize()
                
                let alerview  = UIAlertController(title:"提醒", message: "注册成功,已向您的邮箱发送验证邮件", preferredStyle: .alert)
                let action = UIAlertAction(title: "好" , style: .cancel, handler: nil)
                alerview.addAction(action)
                self.present(alerview, animated: true, completion: nil)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            } else {
                print("失败")
                print(error?.localizedDescription)
            }
        })
    
        
    }
}
