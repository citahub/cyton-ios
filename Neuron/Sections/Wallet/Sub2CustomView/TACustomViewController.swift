//
//  TACustomViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/29.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class TACustomViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    
    let titleArray = ["From","To","Gas限制","旷工费用"]
    
    //还没正式接入 数据写死
    let valueArray = ["s12300sadaf0xz356457fd","s12300sadaf0xz356457fda","2100","2100"]
    

    @IBOutlet weak var countLable: UILabel!
    @IBOutlet weak var taTable: UITableView!
    @IBOutlet weak var sureButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.frame = CGRect(x: 0, y: ScreenH, width: ScreenW, height: ScreenH)
        view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: ScreenW, height: ScreenH)
        }) { (true) in
            self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taTable.delegate = self
        taTable.dataSource = self
        
    }
    
    func setAnimate()  {

    }
    
    @IBAction func didClickCloseButton(_ sender: UIButton) {
        view.removeFromSuperview()
    }
    //点击发送按钮
    @IBAction func didClickSureSendButton(_ sender: UIButton) {
        
    }
    
    //tableview代理
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ID = "ID"
        var cell = tableView.dequeueReusableCell(withIdentifier: ID)
        if cell == nil {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: ID)
            cell?.textLabel?.textColor = ColorFromString(hex: "#888888")
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell?.detailTextLabel?.textColor = ColorFromString(hex: "#333333")
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        
        cell?.textLabel?.text = titleArray[indexPath.row]
        cell?.detailTextLabel?.text = valueArray[indexPath.row]
        
        return cell!
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
