//
//  SignInVC.swift
//  simple
//
//  Created by drf on 2017/9/14.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import AVOSCloud

class SignInVC: UIViewController {

    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var appLabal: UILabel!
    @IBOutlet weak var forgetButton: UIButton!
    
    var tapGuesture : UITapGestureRecognizer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置标题栏的字体
        self.appLabal.font = UIFont(name: "Pacifico", size: 25)
        self.scrollview.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        appLabal.frame = CGRect(x: 20, y: 45, width: UIScreen.main.bounds.width-40, height: 50)
        userIdText.frame = CGRect(x: 20, y: 115, width: self.view.frame.width-40, height: 35)
        passwordText.frame = CGRect(x: 20, y: 170, width: self.view.frame.width-40, height: 35)
        loginButton.frame = CGRect(x: 20, y: 225, width: self.view.frame.width/4, height: 40)
        signupButton.frame = CGRect(x: self.view.frame.width - loginButton.frame.width - 20, y: 225, width: self.view.frame.width / 4, height: 40)
        forgetButton.frame = CGRect(x: self.view.frame.width / 2 - self.signupButton.frame.width / 2, y: self.view.frame.height - 60 , width: signupButton.frame.width, height: 20)
        
        tapGuesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGuesture?.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGuesture!)
        
    }

    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func Login(_ sender: Any) {
        let alertview = UIAlertController(title: "注意", message: "缺失相关信息", preferredStyle: .alert)
        let action = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertview.addAction(action)
        if((userIdText.text?.isEmpty)! || (passwordText.text?.isEmpty)!)
        {
            self.present(alertview, animated: true, completion: nil)
            return
        }
        // 注意，这种方式不安全
        let username = self.userIdText.text
        let password = self.passwordText.text
        
        if username != nil && password != nil {
            AVUser.logInWithUsername(inBackground: username!, password: password!, block: {(user : AVUser? , error: Error?) in
                if error == nil{
                    UserDefaults.standard.set(username,forKey: "username")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.login()
                    
                }
            })
            print("login successed")
            self.view.endEditing(true)
        }
        
    
    }
    

}
