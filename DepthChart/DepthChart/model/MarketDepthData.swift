//
//  MarketDepthData.swift
//  DepthChart
//
//  Created by mqt on 2018/5/25.
//  Copyright © 2018年 mqt. All rights reserved.
//

import UIKit
import SwiftyJSON

open class MarketDepthData: NSObject {
    
    var currencyType: String = ""
    var price: Double = 0
    var quantity = ""
    var exchangeType: ExchangeType?
    
    convenience init(json: JSON, currencyType: String, exchangeType: ExchangeType) {
        self.init()
        self.currencyType = currencyType
        self.exchangeType = exchangeType
        // 修正小数位精度丢失
        let multiplierPrice = NSDecimalNumber.init(string: json[0].stringValue)
        self.price = multiplierPrice.doubleValue
        
        // 修正小数位精度丢失
        let multiplierNumber = NSDecimalNumber.init(string: json[1].stringValue)
        self.quantity = String(format: "%f", multiplierNumber.doubleValue)
        
        
        
        
    }
    
}

/**
 *  交易类型
 */
enum ExchangeType: String {
    case Buy = "1", Sell = "0"
    /**
     返回类型名称
     
     - returns: 返回类型名称
     */
    func typeName() -> String {
        switch self {
        case .Buy:
            return NSLocalizedString("买入", comment: "买入")
        case .Sell:
            return NSLocalizedString("卖出", comment: "卖出")
        }
    }
    
    /**
     返回类型单个字
     
     - returns: 返回类型名称
     */
    func singleChar() -> String {
        switch self {
        case .Buy:
            return NSLocalizedString("买", comment: "买")
        case .Sell:
            return NSLocalizedString("卖", comment: "卖")
        }
    }
    
    /**
     返回类型风格颜色
     
     - returns:
     */
    func typeColor() -> UIColor {
        switch self {
        case .Buy:
            return UIColor(hex: 0xE10B17)
        case .Sell:
            return UIColor(hex: 0x00991A)
        }
    }
    
    func typeLeverColor() -> UIColor {
        switch self {
        case .Buy:
            return UIColor(hex: 0xF3E2E2)
        case .Sell:
            return UIColor(hex: 0xC9E7DE)
        }
    }
    
    func typeSecondColor() -> UIColor {
        switch self {
        case .Buy:
            return UIColor(hex: 0x0B80E0)
        case .Sell:
            return UIColor(hex: 0x0B80E0)
        }
    }
    
    /**
     返回类型风格颜色16进制
     
     - returns:
     */
    func typeColorHEX() -> UInt {
        switch self {
        case .Buy:
            return 0xE10B17
        case .Sell:
            return 0x49AB40
        }
    }
    
    /**
     返回取消按钮图标
     
     - returns:
     */
    func cancelImage() -> UIImage {
        switch self {
        case .Buy:
            return UIImage(named: "ico_deleted")!
        case .Sell:
            return UIImage(named: "ico_deleted")!
        }
    }
    
    /**
     买卖委托的图标
     
     - returns:
     */
    func orderTypeImage() -> UIImage {
        switch self {
        case .Buy:
            return UIImage(named: "ico_type_buy")!
        case .Sell:
            return UIImage(named: "ico_type_sell")!
        }
    }
    
    /// 计划委托名字
    var planOrderName: String {
        switch self {
        case .Buy:
            return "追高抄底"
        case .Sell:
            return "止盈止损"
        }
    }
    
    /// 计划委托-高位名字
    var planOrderUpperName: String {
        switch self {
        case .Buy:
            return "追高"
        case .Sell:
            return "止盈"
        }
    }
    
    /// 计划委托-低位名字
    var planOrderLowerName: String {
        switch self {
        case .Buy:
            return "抄底"
        case .Sell:
            return "止损"
        }
    }
}

extension UIColor {
    
    /**
     16进制表示颜色
     
     - parameter hex:
     
     - returns:
     */
    convenience init(hex: UInt, alpha: Float = 1.0) {
        self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(hex & 0x0000FF) / 255.0,
                  alpha: CGFloat(alpha))
    }
    
    
    
}

extension String{
    
    public func toDouble(_ def: Double = 0.0) -> Double {
        if !self.isEmpty {
            
            //增加欧洲国家数字显示
            let isFind = self.contains(",")
            if isFind
            {
                //self = self.replacingOccurrences(of: ",", with: ".")
                return Double(self.replacingOccurrences(of: ",", with: "."))!
            }
            
            return Double(self)!
        } else {
            return def
        }
    }
}

