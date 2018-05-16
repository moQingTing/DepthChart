//
//  RootViewController.swift
//  PersonalCenter
//
//  Created by mqt on 2018/5/11.
//  Copyright © 2018年 mqt. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    @IBOutlet weak var personalCenterBtn: UIButton!
    
    @IBOutlet weak var switchBg: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.personalCenterBtn.addTarget(self, action: #selector(self.click(sender:)), for: .touchUpInside)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func click(sender:UIButton){
        let vc = PersonalCenterViewController()
        vc.isEnlarge = self.switchBg.isOn
        vc.isRefreshOfdownPull = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}
