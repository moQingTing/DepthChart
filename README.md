# DepthChart 深度图
***注意：该深度图横坐标是以档位为单位，纵坐标是以档位数量为单位***
---
![image](https://github.com/mqtJS/DepthChart/blob/master/2018-05-25%2016_43_00.gif)
---
## Requirements

- iOS 8+
- Xcode 8+
- Swift 4.0+
- iPhone/iPad

### 1、实现代理
```swift
view.delegate = self
```
```swift
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
```
---
### 2、自定义样式
```swift
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
```
---
### 该项目属于二次开发，基于一个`swift`版 `K线` 项目开发
[项目地址](https://github.com/zhiquan911/CHKLineChart)
