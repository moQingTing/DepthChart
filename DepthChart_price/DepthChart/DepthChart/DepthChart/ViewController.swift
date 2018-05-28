//
//  ViewController.swift
//  DepthChart
//
//  Created by mqt on 2018/5/25.
//  Copyright © 2018年 mqt. All rights reserved.
//

import UIKit
import SwiftyJSON
import SnapKit

class ViewController: UIViewController {
    
    /// 深度图: 注意该深度图卖单在左没测试过是否可行
    /// **** 重要的事情要注意一下：该深度图的横坐标是以档位个数为单位，所以没有中间缺口，市面上的深度图的横坐标是以价格范围为横坐标长度 ****
    lazy var depthChart: CHDepthChartView = {
        // 如果使用第三方布局，深度图创建时需要给一个frame,否则不显示
        let view = CHDepthChartView(frame: CGRect(x: 0, y: 0, width: 100, height: 180))
        view.delegate = self
        view.style = .depthStyle
//        view.yAxis.referenceStyle = .solid(color:UIColor(hex:0x2E3F53))
        view.yAxis.referenceStyle = .none
        return view
    }()
    
    /// 卖单买单计算数据源时，注意计算那个数据也有先后的
    var bids = [MarketDepthData](){
        didSet{
            self.decodeDatasToAppend(datas: bids.reversed(), type: .bid)
            self.depthChart.reloadData()
        }
    }
    
    var asks = [MarketDepthData](){
        didSet{
            if self.depthDatas.count > 0{
                self.depthDatas.removeAll()
            }
            self.maxAmount = 0
             self.decodeDatasToAppend(datas: asks, type: .ask)
        }
    }
    
    //最大深度
    var maxAmount: Float = 0
    
    /// 数据源
    var depthDatas: [CHKDepthChartItem] = [CHKDepthChartItem]()
    
    var timerOfDepthChart: Timer?      //刷新深度图定时器
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "深度图"
        self.view.addSubview(self.depthChart)
        self.depthChart.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.size.width)
            make.height.equalTo(180)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startDepthChartTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopDepthChartTimer()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// 解析分析
    func decodeDatasToAppend(datas: [MarketDepthData], type: CHKDepthChartItemType) {
        var total: Float = 0
        
        if datas.count > 0 {
            for data in datas {
                let item = CHKDepthChartItem()
                item.value = CGFloat(data.price)
                item.amount = CGFloat(data.quantity.toDouble())
                item.type = type
                
                self.depthDatas.append(item)
                
                total += Float(item.amount)
            }
        }
        
        if total > self.maxAmount {
            self.maxAmount = total
        }
    }
    

}

extension ViewController{
    
    func startDepthChartTimer() {
        if timerOfDepthChart == nil {
            self.timerOfDepthChart = Timer.scheduledTimer(
                timeInterval: 2,
                target: self,
                selector: #selector(self.getMarketDepth),
                userInfo: nil,
                repeats: true)
        }
    }
    
    //关闭定时器运行
    func stopDepthChartTimer() {
        self.timerOfDepthChart?.invalidate()
        self.timerOfDepthChart = nil
    }
    
    /**
     获取交易订单深度
     */
    @objc func getMarketDepth() {
        // 随机获取文件
        let index = arc4random() % 4 + 1
        let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Market\(index)", ofType: "json")!))
        guard let json = try? JSON(data: data!) else {
            return
        }
        let datas = json["datas"]
        let asksArr = datas["asks"].arrayValue
        var asks = [MarketDepthData]()
        for asksJson in asksArr {
            let ask = MarketDepthData(json: asksJson, currencyType: "", exchangeType: ExchangeType.Sell)
            asks.append(ask)
        }
        let bidsArr = datas["bids"].arrayValue
        var bids = [MarketDepthData]()
        for bidsJson in bidsArr {
            let bid = MarketDepthData(json: bidsJson, currencyType: "", exchangeType: ExchangeType.Buy)
            bids.append(bid)
        }
        self.asks = asks
        self.bids = bids
    }
}

//MARK:深度图表
extension ViewController: CHKDepthChartDelegate {
    
    
    /// 图表的总条数
    /// 总数 = 买方 + 卖方
    /// - Parameter chart:
    /// - Returns:
    func numberOfPointsInDepthChart(chart: CHDepthChartView) -> Int {
        return self.depthDatas.count
    }
    
    
    /// 每个点显示的数值项
    ///
    /// - Parameters:
    ///   - chart:
    ///   - index:
    /// - Returns:
    func depthChart(chart: CHDepthChartView, valueForPointAtIndex index: Int) -> CHKDepthChartItem {
        return self.depthDatas[index]
    }
    
    
    /// y轴以基底值建立
    ///
    /// - Parameter depthChart:
    /// - Returns:
    func baseValueForYAxisInDepthChart(in depthChart: CHDepthChartView) -> Double {
        return 0
    }
    
    /// y轴以基底值建立后，每次段的增量
    ///
    /// - Parameter depthChart:
    /// - Returns:
    func incrementValueForYAxisInDepthChart(in depthChart: CHDepthChartView) -> Double {
        
        //计算一个显示4个辅助线的友好效果
        //        var step = self.maxAmount / 4
        //        var j = 0
        //        while step / 10 > 1 {
        //            j += 1
        //            step = step / 10
        //        }
        //
        //        //幂运算
        //        var pow: Int = 1
        //        if j > 0 {
        //            for _ in 1...j {
        //                pow = pow * 10
        //            }
        //        }
        //
        //        step = Float(lroundf(step) * pow)
        //
        //        return Double(step)
        let step = Double(self.maxAmount / 4)
        print("setp == \(step)")
        return step
    }
    /// 纵坐标值显示间距
    func widthForYAxisLabelInDepthChart(in depthChart: CHDepthChartView) -> CGFloat {
        return 30
    }
    /// 纵坐标值
    func depthChart(chart: CHDepthChartView, labelOnYAxisForValue value: CGFloat) -> String {
        if value >= 1000{
            let newValue = value / 1000
            return newValue.ch_toString(maxF: 0) + "K"
        }else {
            return value.ch_toString(maxF: 1)
        }
    }
    
    /// 价格的小数位
    func depthChartOfDecimal(chart: CHDepthChartView) -> Int {
        return 4
    }
    
    /// 量的小数位
    func depthChartOfVolDecimal(chart: CHDepthChartView) -> Int {
        return 6
    }
    
    //    /// 自定义点击显示信息view
    //    func depthChartShowItemView(chart: CHDepthChartView, Selected item: CHKDepthChartItem) -> UIView? {
    //        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    //        view.backgroundColor = UIColor.red
    //        return view
    //    }
    //    /// 点击标记图
    //    func depthChartTagView(chart: CHDepthChartView, Selected item: CHKDepthChartItem) -> UIView? {
    //        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    //        view.backgroundColor = UIColor.blue
    //        return view
    //    }
}

// MARK: - 扩展样式
extension CHKLineChartStyle {
    
    
    /// 深度图样式
    static var depthStyle: CHKLineChartStyle = {
        
        let style = CHKLineChartStyle()
        //字体大小
        style.labelFont = UIFont.systemFont(ofSize: 10)
        //分区框线颜色
        style.lineColor = UIColor(white: 0.7, alpha: 1)
        //背景颜色
        style.backgroundColor = UIColor.white
        //文字颜色
        style.textColor = UIColor(white: 0.5, alpha: 1)
        //整个图表的内边距
        style.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //Y轴是否内嵌式
        style.isInnerYAxis = false
        //Y轴显示在右边
        style.showYAxisLabel = .right
        
        /// 买单居右
        style.bidChartOnDirection = .left
        
        //边界宽度
        style.borderWidth = (0, 0, 0, 0)
        
        //是否允许手势点击
        style.enableTap = true
        
        //买方深度图层的颜色 UIColor(hex:0xAD6569) UIColor(hex:0x469777)
        style.bidColor = (UIColor(hex:0xAD6569), UIColor(hex:0xAD6569), 1)
        //        style.askColor = (UIColor(hex:0xAD6569), UIColor(hex:0xAD6569), 1)
        //买方深度图层的颜色
        style.askColor = (UIColor(hex:0x469777), UIColor(hex:0x469777), 1)
        //        style.bidColor = (UIColor(hex:0x469777), UIColor(hex:0x469777), 1)
        
        return style
        
    }()
}

public extension CGFloat {
    
    /**
     转化为字符串格式
     
     - parameter minF:
     - parameter maxF:
     - parameter minI:
     
     - returns:
     */
    func ch_toString(_ minF: Int = 2, maxF: Int = 6, minI: Int = 1) -> String {
        let valueDecimalNumber = NSDecimalNumber(value: Double(self) as Double)
        let twoDecimalPlacesFormatter = NumberFormatter()
        twoDecimalPlacesFormatter.maximumFractionDigits = maxF
        twoDecimalPlacesFormatter.minimumFractionDigits = minF
        twoDecimalPlacesFormatter.minimumIntegerDigits = minI
        return twoDecimalPlacesFormatter.string(from: valueDecimalNumber)!
    }
}

