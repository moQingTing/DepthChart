//
//  CenterTouchTableView.swift
//  PersonalCenter
//
//  Created by mqt on 2018/5/15.
//  Copyright © 2018年 mqt. All rights reserved.
//

import UIKit

class CenterTouchTableView: UITableView,UIGestureRecognizerDelegate {

    /// return YES 其他类似手势都响应
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
   
}
