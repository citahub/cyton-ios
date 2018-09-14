//
//  PaymentViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/13.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

class PaymentViewController: UITableViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var assetTypeLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var switchButton: UISwitch!
    private var gasPageViewController: UIPageViewController!
    private var simpleGasViewController: UIViewController!
    private var ethGasViewController: UIViewController!
    private var nervosQuoteViewController: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "转账"

        simpleGasViewController = storyboard!.instantiateViewController(withIdentifier: "simpleGasViewController") as! SimpleGasViewController
        ethGasViewController = storyboard!.instantiateViewController(withIdentifier: "ethGasViewController") as! EthGasViewController
        nervosQuoteViewController = storyboard!.instantiateViewController(withIdentifier: "nervosQuoteViewController") as! NervosQuoteViewController
        gasPageViewController.setViewControllers([simpleGasViewController], direction: .forward, animated: false)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gasPageViewController" {
            gasPageViewController = segue.destination as? UIPageViewController
        }
    }

}
