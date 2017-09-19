//
//  ResetPasswordVC.swift
//  simple
//
//  Created by drf on 2017/9/15.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import AVOSCloud

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailText.frame = CGRect(x: 20, y: 60, width: self.view.frame.width - 40, height: 35)
        self.resetButton.frame = CGRect(x: 20, y: 115 , width: self.view.frame.width / 4, height: 40)
        self.cancelButton.frame = CGRect(x: self.view.frame.width - resetButton.frame.width - 20, y: 115, width: self.view.frame.width / 4, height: 40)
    }

    @IBAction func ResetPassword(_ sender: Any) {
        if (emailText.text?.isEmpty)! {
            let alertView = UIAlertController(title: "请注意", message: "电子邮箱不能为空", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertView.addAction(ok)
            self.present(alertView, animated: true, completion: nil)
            return
        }
        
        AVUser.requestPasswordResetForEmail(inBackground: emailText.text!, block: { (success : Bool , error :Error?) in
            if success {
                let alertView = UIAlertController(title: "请注意", message: "密码重置邮件已发到您的邮箱", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertView.addAction(ok)
                self.present(alertView, animated: true, completion: nil)
            } else {
                print(error!.localizedDescription)
            }
            
        })
        
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
