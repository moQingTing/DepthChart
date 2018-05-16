//
//  SegmentViewController.swift
//  PersonalCenter
//
//  Created by mqt on 2018/5/16.
//  Copyright © 2018年 mqt. All rights reserved.
//

import UIKit

class SegmentViewController: UIViewController,UIScrollViewDelegate{
    /// 是否可以滚动
    var canScroll = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //子控制器视图到达顶部的通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.acceptMsg(notification:)), name: NSNotification.Name(rawValue: "goTop"), object: nil)
        //子控制器视图离开顶部的通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.acceptMsg(notification:)), name: NSNotification.Name(rawValue: "leaveTop"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func acceptMsg(notification:Notification){
        let notificationName = notification.name
        if notificationName.rawValue == "goTop"{
            guard let userInfo = notification.userInfo else{
                return
            }
            let canScroll = userInfo["canScroll"] as! String
            if canScroll == "1"{
                self.canScroll = true
            }
        }else if notificationName.rawValue == "leaveTop"{
            self.canScroll = false
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.canScroll{
            scrollView.setContentOffset(CGPoint.zero, animated: false)
        }
        let offsetY = scrollView.contentOffset.y
        
        if offsetY < 0{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leaveTop"), object: nil, userInfo: ["canScroll":"1"])
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
