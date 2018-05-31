//
//  SubController2.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/21.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class SubController2: BaseViewController,UITableViewDelegate,UITableViewDataSource,AssetsDetailControllerDelegate {
    var isChangeWallet = false//是否显示切换钱包 默认不显示
    
    @IBOutlet weak var setUpButton: UIButton!
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var namelable: UILabel!
    @IBOutlet weak var mAddress: UILabel!
    @IBOutlet weak var archiveBtn: UIButton!
    @IBOutlet weak var manageBtn: UIButton!
    
    @IBOutlet weak var mainTable: UITableView!
    let sCtrl = SelectWalletController.init(nibName: "SelectWalletController", bundle: nil)
    let aCtrl = AssetsDetailController.init(nibName: "AssetsDetailController", bundle: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "钱包"
        //这个必须写在构建UI之前。。必须必须
//        UIApplication.shared.keyWindow?.addSubview(sCtrl.view)
//        sCtrl.view.isHidden = true
        aCtrl.delegate = self;
        setUpSubViewDetails()
    }
    
    func setUpSubViewDetails() {
        headView.layer.shadowColor = ColorFromString(hex: "#ededed").cgColor
        headView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headView.layer.shadowOpacity = 0.3
        headView.layer.shadowRadius = 2.75
        headView.layer.cornerRadius = 5
        headView.layer.borderWidth = 1
        headView.layer.borderColor = ColorFromString(hex: "#ededed").cgColor
        
        mainTable.delegate = self
        mainTable.dataSource = self
        mainTable.register(UINib.init(nibName: "Sub2TableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        
        //设置左右导航按钮
        let leftBtn = UIButton.init(type: .custom)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        leftBtn.setImage(UIImage.init(named: "列表"), for: .normal)
        leftBtn.addTarget(self, action: #selector(didChangeWallet), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftBtn)
        
        let rightBtn = UIButton.init(type: .custom)
        rightBtn.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        rightBtn.setImage(UIImage.init(named: "添加"), for: .normal)
        rightBtn.addTarget(self, action: #selector(didAddWallet), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
        
    }
    
    //点击头部两个按钮
    //收款
    @IBAction func didClickArchiveBtn(_ sender: UIButton) {
        let rCtrl = ReceiveController.init(nibName: "ReceiveController", bundle: nil)
        navigationController?.pushViewController(rCtrl, animated: true)
    }
    //点击资产管理按钮
    @IBAction func didClickManageBtn(_ sender: UIButton) {
        let aCtrl = AssetViewController.init(nibName: "AssetViewController", bundle: nil)
        navigationController?.pushViewController(aCtrl, animated: true)
        
    }
    //点击设置按钮
    @IBAction func didClickSetupBtn(_ sender: Any) {
        let wCtrl = WalletDetailController.init(nibName: "WalletDetailController", bundle: nil)
        navigationController?.pushViewController(wCtrl, animated: true)
    }
    
    //切换钱包
    @objc func didChangeWallet(){
        UIApplication.shared.keyWindow?.addSubview(sCtrl.view)
    }
    //新增钱包
    @objc func didAddWallet(){
        let aCtrl = AddWalletController.init(nibName: "AddWalletController", bundle: nil)
        navigationController?.pushViewController(aCtrl, animated: true)
        
    }
    
    
    //弹出界面点击按钮的代理事件
    //点击付款
    func didClickPay() {
        print("付款")
        let tCtrl =  TAViewController.init(nibName: "TAViewController", bundle: nil)
        navigationController?.pushViewController(tCtrl, animated: true)
    }
    //点击收款
    func didClickGet() {
        print("收款")
        let rCtrl = ReceiveController.init(nibName: "ReceiveController", bundle: nil)
        navigationController?.pushViewController(rCtrl, animated: true)
    }
    
    

    
    //tableview代理
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath) as! Sub2TableViewCell
        cell.titlelable.text = "ETH"
        cell.iconImage.image = UIImage.init(named: "ETH_test")
        cell.countLable.text = "100.00"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        UIApplication.shared.keyWindow?.addSubview(aCtrl.view)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    


}
