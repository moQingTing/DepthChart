//
//  ViewController.swift
//  PersonalCenter
//
//  Created by mqt on 2018/5/11.
//  Copyright © 2018年 mqt. All rights reserved.
//

import UIKit
import SnapKit

class PersonalCenterViewController: UIViewController {

    /// 是否放大
    var  isEnlarge = false
    
    /// 下拉操作下方talbeView 是否刷新
    var isRefreshOfdownPull = false
    
    /// 当前选中的分页视图下标
    var selectIndex = 0
    
    /// mainTableView是否可以滚动
    var canScroll = false
    
    /// 到达顶部(临界点)不能移动mainTableView
    var isTopIsCanNotMoveTabView = false
    
    /// 到达顶部(临界点)不能移动子控制器的tableView
    var isTopIsCanNotMoveTabViewPre = false
    
    /// 导航栏的高度+状态栏的高度
    var naviBarHeight:CGFloat = 0
    
    /// 控制下拉放大时刷新数据的次数，做到下拉放大值刷新一次，避免重复刷新
    var isRefresh = false
    
    /// 头像距离顶部高度
    var headimageHeight:CGFloat = 240
    
    /// 分页菜单栏的高度
    var segmentMenuHeight:CGFloat = 41
    
    /// 是否第一次初始化
    var isInit = false
    
    /// 外层tableView
    lazy var mainTableView:CenterTouchTableView = {
        //⚠️这里的属性初始化一定要放在mainTableView.contentInset的设置滚动之前, 不然首次进来视图就会偏移到临界位置，contentInset会调用scrollViewDidScroll这个方法。
        //初始化变量
        self.canScroll = true
        self.isTopIsCanNotMoveTabView = false
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        let view = CenterTouchTableView(frame: frame, style: UITableViewStyle.plain)
        view.delegate = self
        view.dataSource = self
        view.showsVerticalScrollIndicator = false
        
         //注意：这里不能使用动态高度_headimageHeight, 不然tableView会往下移，在iphone X下，头部不放大的时候，上方依然会有白色空白
        view.contentInset = UIEdgeInsets(top: self.headimageHeight, left: 0, bottom: 0, right: 0)
        return view
    }()
    
    /// 分栏视图，头部视图下方区域
    lazy var segView:CenterSegmentView = {
        let nameArray = ["普吉岛","夏威夷","洛杉矶","杭州","长城"]
        let vc1 = FirstViewController()
        let vc2 = SecondViewController()
        let vc3 = ThirdViewController()
        let vc4 = FirstViewController()
        let vc5 = SecondViewController()
        
        let controollers = [vc1,vc2,vc3,vc4,vc5]
        
        let view = CenterSegmentView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height - self.naviBarHeight), controllers: controollers, titleArray: nameArray, selectIndex: self.selectIndex, lineHeight: 2)
        return view
    }()
    
    /// 自定义导航栏
    lazy var naviView:UIView = {
       let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.naviBarHeight))
        view.backgroundColor = UIColor.init(white: 1, alpha: 0)
        //添加按钮
        view.addSubview(self.backButton)
        view.addSubview(self.messageButton)
        return view
    }()
    
    /// 导航栏-返回按钮
    lazy var backButton:UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.setImage(UIImage(named: "back"), for: .normal)
        btn.frame = CGRect(x: 5, y: 28 + self.naviBarHeight - 64, width: 28, height: 25)
        btn.adjustsImageWhenHighlighted = false
        btn.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        return btn
    }()
    
    /// 导航栏-消息按钮
    lazy var messageButton:UIButton = {
       let btn = UIButton(type: UIButtonType.custom)
        btn.setImage(UIImage(named: "message"), for: .normal)
        btn.frame = CGRect(x: UIScreen.main.bounds.size.width - 35, y: 28 + self.naviBarHeight - 64, width: 25, height: 25)
        btn.adjustsImageWhenHighlighted = false
        btn.addTarget(self, action: #selector(self.checkMessage), for: .touchUpInside)
        return btn
    }()
    
    /// 头部背景视图
    lazy var headImageView:UIImageView = {
       let imgView = UIImageView(image: UIImage(named: "center_bg"))
        imgView.backgroundColor = UIColor.green
        imgView.isUserInteractionEnabled = true
        imgView.frame = CGRect(x: 0, y: -self.headimageHeight, width: UIScreen.main.bounds.size.width, height: self.headimageHeight)
        return imgView
    }()
    
    /// 头部内容视图，放置用户信息，如：姓名，昵称、座右铭等(作用：背景放大不会影响内容的位置)
    lazy var headContentView:UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    /// 头像
    lazy var avatarImage:UIImageView = {
       let view = UIImageView()
        view.image = UIImage(named: "center_avatar")
        view.isUserInteractionEnabled = true
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 255/255, green: 253/255, blue:  253/255, alpha: 1).cgColor
        view.layer.cornerRadius = 40
        return view
    }()
    
    /// 昵称
    lazy var nickNameLB:UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        label.text = "带你去浪漫的土耳其"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setConstraint()
        NotificationCenter.default.addObserver(self, selector: #selector(self.acceptMsg(notification:)), name: NSNotification.Name(rawValue: "leaveTop"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //隐藏原生导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.naviView.isHidden = false
        //允许执行scrollViewDidScroll的逻辑
        self.isInit = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //显示原生导航栏
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.naviView.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupUI(){
//        self.automaticallyAdjustsScrollViewInsets = false
        self.naviBarHeight = UIScreen.main.bounds.size.height == 812 ? 88 : 64
        //如果使用自定义的按钮去替换系统默认返回按钮，会出现滑动返回手势失效的情况，解决方法如下：
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.title = "个人中心"
        self.view.backgroundColor = UIColor.white
        
        if #available(iOS 11.0, *) {
            self.mainTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.mainTableView.addSubview(self.headImageView)
    }
    
    func setConstraint(){
        self.view.addSubview(self.mainTableView)
        
        
        
        self.view.addSubview(self.naviView)
        
        
        headImageView.addSubview(self.headContentView)
        headContentView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.headImageView)
            make.centerX.equalTo(self.headImageView.snp.centerX)
            make.width.equalToSuperview()
            make.height.equalTo(self.headimageHeight)
        }
        
        //添加头像
        self.headContentView.addSubview(self.avatarImage)
        self.avatarImage.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.headContentView)
            make.width.equalTo(80)
            make.height.equalTo(80)
            make.bottom.equalTo(-70)
        }
        
        headImageView.addSubview(self.nickNameLB)
        nickNameLB.snp.makeConstraints { (make) in
            make.centerX.equalTo(headContentView)
            make.width.equalTo(200)
            make.height.equalTo(25)
            make.bottom.equalTo(-40)
        }
        
    }
    @objc func backAction(){
        print("点击返回")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func checkMessage(){
        print("点击消息")
        let vc = FirstViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func acceptMsg(notification:Notification){
        guard let userInfo = notification.userInfo else{
            return
        }
        guard let canScroll = userInfo["canScroll"] else{
            return
        }
       
        let canScrol = canScroll as! String
        if canScrol == "1"{
             print("接受到消息，允许mainTableView滑动")
            self.canScroll = true
        }
    
    }
    
    /**
     * 处理联动
     * 因为要实现下拉头部放大的问题，tableView设置了contentInset，所以试图刚加载的时候会调用一遍这个方法，所以要做一些特殊处理，
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 第一次进来先不执行，不然mainTable报错
        if !self.isInit{
            return
        }
        // 当前偏移量
        let yOffset = scrollView.contentOffset.y
//        // 临界点偏移量
        let tabyOffset = self.mainTableView.rect(forSection: 0).origin.y - self.naviBarHeight
        print("yOffset == \(yOffset)")
        print("headimageHeight ==\(self.headimageHeight)")
        print("tabyOffset == \(tabyOffset)")
        
        //第一部分
        // 更改导航栏的背景图的透明度
        var alpha:CGFloat = 0
        if (-yOffset <= self.naviBarHeight){
            alpha = 1
        }else if 88 < -yOffset && -yOffset < self.headimageHeight{
            alpha = (self.headimageHeight + yOffset) / (self.headimageHeight - self.naviBarHeight)
        }else{
            alpha = 0
        }
        self.naviView.backgroundColor = UIColor(red: 255/255, green: 126/255, blue:  15/255, alpha: alpha)

        //第二部分
        //注意：先解决mainTableView的bance问题，如果不用下拉头部刷新/下拉头部放大/为了实现subTableView下拉刷新
        //1. 不用下拉顶部刷新、不用下拉头部放大、使用subTableView下拉顶部刷新， 可在mainTableView初始化时禁用bance；
         //2. 如果做下拉顶部刷新、下拉头部放大，就需要对bance做处理，不然当视图滑动到底部后，内外层的scrollView的bance都会起作用，导致视觉上的幻觉(刚滑动到底部/触发内部scrollView的bance的时候，再去点击cell/item/button, 你会发现竟然不管用，再次点就好了，刚开始还以为是点击事件和滑动事件的冲突，后来通过offset的log，发现当内部bance触发的时候，你感觉不到外层bance的变化，并且你会看见，当前列表已经停止滚动了，但是外层scrollView的offset还在变，所以导致首次点击事件失效)
        
//        if yOffset > 0 {
//            scrollView.bounces = false
//        }else{
//            scrollView.bounces = true
//        }
        
        //利用contentOffset处理内外层scrollView的滑动冲突问题
        if yOffset >= tabyOffset{
            scrollView.contentOffset = CGPoint(x: 0, y: tabyOffset)
            self.isTopIsCanNotMoveTabView = true
        }else{
            //当分页视图和顶部导航栏分离时，允许外层tableView滑动
            self.isTopIsCanNotMoveTabView = false
        }
        
        self.isTopIsCanNotMoveTabViewPre = !self.isTopIsCanNotMoveTabView
        if (!self.isTopIsCanNotMoveTabViewPre && self.isTopIsCanNotMoveTabView){
                print("滑动顶部")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "goTop"), object: nil, userInfo: ["canScroll":"1"])
            self.canScroll = false
        }
        
        if self.isTopIsCanNotMoveTabViewPre && !self.isTopIsCanNotMoveTabView{
            print("滑动到底部开始啦")
            if !self.canScroll{
                print("保持在顶端")
                scrollView.contentOffset = CGPoint(x: 0, y: tabyOffset)
            }
        }
        
        //第三部
        /**
         * 处理头部自定义背景视图 (如: 下拉放大)
         * 图片会被拉伸多出状态栏的高度
         */
        if yOffset <= -headimageHeight{
            //是否被拉伸
            if self.isEnlarge{
                var f = self.headImageView.frame
                //改变headImageView的frame
                //上下放大
                f.origin.y = yOffset
                f.size.height = -yOffset
                let width = UIScreen.main.bounds.size.width
                //左右放大
                f.origin.x = (yOffset * width / self.headimageHeight + width) / 2
                f.size.width = -yOffset * width / self.headimageHeight
                
                self.headImageView.frame = f
                
                //刷新数据，保证刷新一次
                if -yOffset == self.headimageHeight{
                    self.isRefresh = true
                }
                if yOffset < -self.headimageHeight - 30 && self.isRefresh{
                    ///刷新数据处理。。。。
                    print("刷新数据处理。。。。")
                    self.isRefresh = false
                }
            }else{
               self.mainTableView.bounces = false
                if -yOffset == self.headimageHeight{
                    ///刷新数据处理。。。。
                    print("刷新数据处理。。。。")
                }
            }
            
            if self.isRefreshOfdownPull{
                ///刷新数据处理。。。。
                print("刷新数据处理。。。。")
            }
        }
        
    }

}

extension PersonalCenterViewController:UIGestureRecognizerDelegate{
    //处理左滑右滑，解决系统右划手势与ScrollView右划手势冲突
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if otherGestureRecognizer.state == .began && self.segView.segmentScrollV.contentOffset.x == 0{
            return true
        }
        return false
    }
}



extension PersonalCenterViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        // 添加segmentView
        cell.contentView.addSubview(self.segView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height - self.naviBarHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = FirstViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

