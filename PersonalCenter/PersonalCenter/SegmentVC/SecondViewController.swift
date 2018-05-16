//
//  SecondViewController.swift
//  PersonalCenter
//
//  Created by mqt on 2018/5/11.
//  Copyright © 2018年 mqt. All rights reserved.
//

import UIKit

class SecondViewController: SegmentViewController {

    lazy var tableView:UITableView = {
       let view = UITableView(frame: self.view.bounds)
        view.delegate = self
        view.dataSource = self
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.separatorStyle = .singleLine
        view.rowHeight = 50
        
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
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

extension SecondViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "SecondVCcell"
        var cell:UITableViewCell?
        if let c = tableView.dequeueReusableCell(withIdentifier: identifier){
            cell = c
        }else{
            cell = UITableViewCell(frame: CGRect.zero)
        }
        cell!.textLabel?.text = "你好，世界！+ \(indexPath.row)"
        return cell!
    }
    
    
}
