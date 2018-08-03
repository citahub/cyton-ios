//
//  TAViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/28.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import BigInt
import web3swift

class TAViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,AddAssetTableViewCellDelegate,TAViewControllerCellDelegate,QRCodeControllerDelegate,TACustomViewControllerDelegate {

    let nameArray = ["地址","转账金额"]
    let plactholderArray = ["输入转账地址或扫码","转账金额"]
    
    let tCtrl = TACustomViewController.init(nibName: "TACustomViewController", bundle: nil)
    let viewModel = TAViewModel()
    let appModel = WalletRealmTool.getCurrentAppmodel()
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var walletName: UILabel!
    @IBOutlet weak var walletAddress: UILabel!
    @IBOutlet weak var tTable: UITableView!
    
    var gasPrice = BigUInt()
    var letGasP = BigUInt()
    
    var totleGas = BigUInt()
    var estimatedGas:String?
    var tableProgress:Float = 25.00
    
    var toAddress:String = ""
    var amount:String = ""
    var tokenModel = TokenModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "转账"
        tTable.delegate = self
        tTable.dataSource = self
        tTable.isScrollEnabled = false
        tTable.register(UINib.init(nibName: "AddAssetTableViewCell", bundle: nil), forCellReuseIdentifier: "ID")
        tTable.register(UINib.init(nibName: "TAViewControllerCell", bundle: nil), forCellReuseIdentifier: "ID1")
        tCtrl.delegate = self
        
        iconImage.image = UIImage(data: (appModel.currentWallet?.iconData)!)
        walletName.text = appModel.currentWallet?.name
        walletAddress.text = appModel.currentWallet?.address
        didGetGasPrice()
    }
    
    func didGetGasPrice() {
        NeuLoad.showHUD(text: "")
        viewModel.getGasPrice { (result) in
            switch result{
            case .Success(let gasP):
                self.letGasP = gasP
                self.totleGas = gasP * BigUInt(21000)
                self.getGasPriceAndPriceLimit(progress: self.tableProgress)
            case .Error(let error):
                NeuLoad.showToast(text: error.localizedDescription)
            }
            NeuLoad.hidHUD()
        }
    }
    
    func getGasPriceAndPriceLimit(progress:Float) {
        gasPrice = letGasP * BigUInt(progress)
        let finalGas = totleGas
        let formatGasPrice = Web3.Utils.formatToEthereumUnits(finalGas, toUnits: .eth, decimals: 8)!
        let showGas = Float(formatGasPrice)! * progress
        estimatedGas = String(format: "%.8f", showGas)
        let index = IndexPath.init(row: 2, section: 0)
        self.tTable.reloadRows(at: [index], with: .none)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return 80
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ID1", for: indexPath) as! TAViewControllerCell
            cell.contentView.isUserInteractionEnabled = true
            cell.progress = tableProgress
            cell.showGasPrice = estimatedGas ?? ""
            cell.delegate = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ID") as! AddAssetTableViewCell
            cell.delegate = self
            cell.headLable.text = nameArray[indexPath.row]
            cell.placeHolderStr = plactholderArray[indexPath.row]
            cell.indexP = indexPath as NSIndexPath
            print(indexPath.row)
            if indexPath.row == 0  {
                cell.selectRow = 1
                cell.rightTextField.text = toAddress
            }else{
                cell.isOnlyNumberAndPoint = true
                cell.selectRow = 3
            }
            
            return cell
        }
    }
    
    //cell代理
    //textfield内容
    func didGetTextFieldTextWithIndexAndText(text: String, index: NSIndexPath) {
        switch index.row {
        case 0:
            toAddress = text
            break
        case 1:
            amount = text
            break
        default:
            break
        }
    }
    //拉动进度条返回的进度 0~1之间
    func didCallbackCurrentProgress(progress: Float) {
        tableProgress = progress
        getGasPriceAndPriceLimit(progress: tableProgress)
    }
    
    //界面本身的点击事件
    //点击qrcode
    func didClickQRCodeBtn() {
        let qrCtrl = QRCodeController()
        qrCtrl.delegate = self
        self.navigationController?.pushViewController(qrCtrl, animated: true)
    }
    //点击下一步
    @IBAction func didClickNextButton(_ sender: UIButton) {
        if toAddress.isEmpty {NeuLoad.showToast(text: "请输入转账地址")
            return
        }
        if !toAddress.hasPrefix("0x") || toAddress.count != 42 {
            NeuLoad.showToast(text: "地址有误:地址一般为0x开头的42位字符")
            return
        }
        if amount.isEmpty {NeuLoad.showToast(text: "请输入转账金额")
            return
        }
        if (estimatedGas?.isEmpty)! {
            return
        }
        
        UIApplication.shared.keyWindow?.addSubview(tCtrl.view)
        tCtrl.gasPrice = gasPrice
        tCtrl.amountStr = amount
        tCtrl.destinationAddress = toAddress
        tCtrl.estimatedGas = estimatedGas!
        tCtrl.tokenModel = tokenModel
    }
    
    func successPop() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    //QRCode delegate
    func didBackQRCodeMessage(codeResult: String) {
        toAddress = codeResult
        let index = IndexPath.init(row: 2, section: 0)
        self.tTable.reloadRows(at: [index], with: .none)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
