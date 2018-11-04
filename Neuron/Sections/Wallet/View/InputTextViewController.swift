//
//  WalletPasswordCheckViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/3.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class InputTextViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textField: UITextField!
    var confirmHandler: ((InputTextViewController, String) -> Void)?
    var cancelHandler: ((InputTextViewController) -> Void)?

    static func viewController(
        title: String,
        placeholder: String,
        isSecureTextEntry: Bool,
        confirmHandler: @escaping (InputTextViewController, String) -> Void,
        cancelHandler: @escaping (InputTextViewController) -> Void) -> InputTextViewController {
        let input: InputTextViewController = UIStoryboard(name: .walletManagement).instantiateViewController()
        _ = input.view // load view
        input.titleLabel.text = title
        input.textField.placeholder = placeholder
        input.textField.isSecureTextEntry = isSecureTextEntry
        input.confirmHandler = confirmHandler
        input.cancelHandler = cancelHandler
        return input
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundView.alpha = 0.0
        contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.size.height)
        UIView.animate(withDuration: 0.33, animations: {
            self.backgroundView.alpha = 1.0
            self.contentView.transform = CGAffineTransform.identity
        }, completion: { (_) in
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !textField.isEditing {
            dismiss()
        }
    }

    @IBAction func cancel(_ sender: Any) {
        cancelHandler?(self)
    }

    @IBAction func confirm(_ sender: Any) {
        let text = textField.text ?? ""
        confirmHandler?(self, text)
    }

    func dismiss() {
        UIView.animate(withDuration: 0.33, animations: {
            self.backgroundView.alpha = 0.0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: self.contentView.bounds.size.height)
        }, completion: { (_) in
            self.dismiss(animated: false, completion: nil)
        })
    }

    func show(in viewController: UIViewController) {
        modalPresentationStyle = .overCurrentContext
        viewController.present(self, animated: false, completion: nil)
    }
}
