//
//  CHKLineChartStyle.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/9/19.
//  Copyright © 2016年 Chance. All rights reserved.
//
import Foundation
import UIKit

open class CHShapeLayer: CAShapeLayer {
    
    // 关闭 CAShapeLayer 的隐式动画，避免滑动时候或者十字线出现时有残影的现象(实际上是因为 Layer 的 position 属性变化而产生的隐式动画)
    open override func action(forKey event: String) -> CAAction? {
        return nil
    }
}

open class CHTextLayer: CATextLayer {
    
    // 关闭 CAShapeLayer 的隐式动画，避免滑动时候或者十字线出现时有残影的现象(实际上是因为 Layer 的 position 属性变化而产生的隐式动画)
    open override func action(forKey event: String) -> CAAction? {
        return nil
    }
}

