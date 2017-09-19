//
//  TabBarVC.swift
//  simple
//
//  Created by drf on 2017/9/18.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 字体颜色
        self.tabBar.tintColor = .white
        // 背景颜色
        self.tabBar.barTintColor = UIColor(red: 37.0/255.0, green: 39.0/255.0, blue: 42.0/255.0, alpha: 1)
        // 不透明
        self.tabBar.isTranslucent = false
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
