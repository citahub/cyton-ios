//
//  AddWalletController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class AddWalletController: BaseViewController {

    @IBOutlet weak var buildWalletBtn: UIButton!
    @IBOutlet weak var importWalletBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "新增钱包"
        view.backgroundColor = UIColor.white
    }
    //生成钱包
    @IBAction func didBuildWallet(_ sender: UIButton) {
        let cCtrl  = CreatWalletController.init(nibName: "CreatWalletController", bundle: nil)
        navigationController?.pushViewController(cCtrl, animated: true)
    }
    //导入钱包
    @IBAction func didImportWallet(_ sender: UIButton) {
        let iCtrl = ImportWalletController.init(nibName: "ImportWalletController", bundle: nil)
        navigationController?.pushViewController(iCtrl, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
