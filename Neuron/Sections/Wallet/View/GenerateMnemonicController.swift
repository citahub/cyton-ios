//
//  GenerateMnemonicController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/1.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class GenerateMnemonicController: BaseViewController {

    @IBOutlet weak var mnemonicTextView: UITextView!
    @IBOutlet weak var nextButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "备份助记词"
        mnemonicTextView.layer.borderColor = ColorFromString(hex: "#eeeeee").cgColor
        mnemonicTextView.layer.borderWidth = 1
        mnemonicTextView.isEditable = false
    }

    @IBAction func didClickNextButton(_ sender: UIButton) {
        
        let sCtrl = SureMnemonicViewController.init(nibName: "SureMnemonicViewController", bundle: nil)
        navigationController?.pushViewController(sCtrl, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
