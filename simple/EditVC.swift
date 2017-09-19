//
//  EditVC.swift
//  simple
//
//  Created by drf on 2017/9/17.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import AVOSCloud

class EditVC: UIViewController , UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var webText: UITextField!
    @IBOutlet weak var introTextView: UITextView!
    @IBOutlet weak var imfoLabel: UILabel!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var sexText: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userimageView: UIImageView!
    var genderPicker : UIPickerView!
    let genders = ["男","女"]
    var keyboard = CGRect()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userimageView.layer.cornerRadius = 40
        userimageView.clipsToBounds = true
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        sexText.inputView = genderPicker
        // 点击空白处隐藏键盘
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(hideTap)
        // 处理键盘高度
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        // 更换用户头像
        let changeTap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        changeTap.numberOfTapsRequired = 1
        userimageView.isUserInteractionEnabled = true
        userimageView.addGestureRecognizer(changeTap)
        imformation()
        
        
        // 添加导航栏按钮
        let leftButton = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(Cancel(_:)))
        let rightButton = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(Save(_:)))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.leftBarButtonItem = leftButton
    
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }

    @IBAction func Save(_ sender: Any) {
        // 检查数据有效性
        if !validateWeb(web: webText.text!){
            alert(error: "错误的网站信息", message: "请输入正确的网站信息")
            return
        }
        if !validateEmail(email: emailText.text!){
            alert(error: "错误的邮箱", message: "请输入正确的邮箱")
            return
        }
        
        if !validatePhoneNumber(num: phoneText.text!){
            alert(error: "错误的手机号码", message: "请输入正确的手机号码")
            return
        }
        
        let user = AVUser.current()
        user?["fullname"] = nameText.text!
        user?.saveInBackground({(success: Bool, error:Error?) in
            if success  {
            self.view.endEditing(true)
            print("更新信息成功")
            self.dismiss(animated: true, completion: nil)
            } else {
                print(error!.localizedDescription)
            }
    })
        
        
    }
    
    func alert(error : String, message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func Cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: pickerView datasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.sexText.text = genders[row]
        self.view.endEditing(true)
        
    }
    // MARK: coumstom functions 
    func hideKeyboard(){ self.view.endEditing(true) }
    func keyboardWillShow(notification: Notification){ let rect  = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboard = rect.cgRectValue
        UIView.animate(withDuration: 0.4, animations: {
            self.scrollView.contentSize.height = self.view.frame.height + self.keyboard.height / 2
            self.scrollView.frame.origin.y  = self.view.frame.origin.y - self.keyboard.height / 2
            print("调整高度")
        })
        
    }
    
    func keyboardWillDisappear(notification : Notification){
        UIView.animate(withDuration: 0.4, animations: {
            self.scrollView.contentSize.height = 0
            print("调整高度")
        })
    }
    
    func imformation(){
        // 当用户编辑信息时，显示当前用户的头像
        let ava = AVUser.current()?.object(forKey: "ava") as! AVFile
        ava.getDataInBackground({(data : Data?,error: Error?) in
            if error == nil {
                self.userimageView.image = UIImage(data: data!)
                print("获取用户信息成功")
            } else {
                print("获取用户信息失败")
                print(error!.localizedDescription)
            }
        })
    }
    
    // 使用正则表达式检查数据有效性
    func validateEmail(email : String) -> Bool {
        let regex = "\\w[-\\w.+]*@([A-Za-z0-9][A-Za-z0-9]+\\.)+[A-Za-z]{2,14}"
        let range = email.range(of: regex,options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func validateWeb(web: String) -> Bool {
        let regex = "www\\.[A-Za-z0-9._%+-]+\\.[A-Za-z]{2,14}"
        let range = web.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func validatePhoneNumber(num : String) -> Bool {
        let regex = "0?(13|14|15|18)[0-9]{9}"
        let range = num.range(of: regex,options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
}

extension EditVC : UIImagePickerControllerDelegate ,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        userimageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func selectImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
}

