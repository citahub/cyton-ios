//
//  SwitchChainViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/12/10.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class SwitchChainViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Assets.AddAssets.SwitchChainNetWorkTitle".localized()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundView.alpha = 0.0
        contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.size.height)
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.backgroundView.alpha = 1.0
            self.contentView.transform = CGAffineTransform.identity
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss()
    }

    @IBAction func dismiss() {
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
            self.backgroundView.alpha = 0.0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: self.contentView.bounds.size.height)
        }, completion: { (_) in
            self.dismiss(animated: false, completion: nil)
        })
    }
}

extension SwitchChainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "switchChainTableViewCell") as! SwitchChainTableViewCell
        cell.networkLabel.text = "q以太坊"
        cell.selectedImageView.isHidden = false
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}


class SwitchChainTableViewCell: UITableViewCell {
    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
}
