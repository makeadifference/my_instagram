//
//  ViewController.swift
//  simple
//
//  Created by drf on 2017/9/13.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import AVOSCloud

class ViewController: UIViewController , UITextFieldDelegate {
    @IBOutlet weak var text1: UITextField!
    @IBOutlet weak var text2: UITextField!
    @IBOutlet weak var text3: UITextField!
    @IBOutlet weak var text4: UITextField!
    @IBOutlet weak var cencelButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    
    var tapRecognizer : UITapGestureRecognizer?
    var height :CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
        //textview delegate
        
        // 设置UI组件布局
        text1.frame = CGRect(x: 10, y: 120, width: self.view.frame.width-20, height: 40)
        text2.frame = CGRect(x: 10, y: 170, width: self.view.frame.width-20, height: 40)
        text3.frame = CGRect(x: 10, y: 220, width: self.view.frame.width-20, height: 40)
        text4.frame = CGRect(x: 10, y: 270, width: self.view.frame.width-20, height: 40)
        cencelButton.frame = CGRect(x: 10, y: 350, width: self.view.frame.width/4, height: 40)
        signupButton.frame = CGRect(x: self.view.frame.width/4*3-5, y: 350, width: self.view.frame.width/4, height: 40)
        userImage.frame = CGRect(x: self.view.frame.width/2-40, y: 20, width: 80, height: 80)
        userImage.layer.cornerRadius = userImage.frame.width/2
        userImage.clipsToBounds = true
        // 手势控制
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapRecognizer?.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillshow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    func keyboardWillshow(notification:Notification){
        print("keyboard will show")
       let temp = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let height1 = temp.cgRectValue
        self.height = height1.height
        self.view.frame.origin.y = self.view.frame.origin.y - height!
        
        
    }
    
    func keyboardWillHide(notification:Notification){
        print("keyboard will hide")
        self.view.frame.origin.y = self.view.frame.origin.y + height!
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        text1.resignFirstResponder()
        return true
    }
    


}

