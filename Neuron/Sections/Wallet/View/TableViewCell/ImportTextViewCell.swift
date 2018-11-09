//
//  ImportTextViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/31.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView

protocol ImportTextViewCellDelegate: class {
    func didClickQRBtn()
    func didGetTextViewText(text: String)
}

class ImportTextViewCell: UITableViewCell, UITextViewDelegate {

    var placeHolderStr: String! {
        didSet {
            textView.placeholder = placeHolderStr as NSString?
            textView.text = ""
        }
    }

    weak var delegate: ImportTextViewCellDelegate?
    let textView = RSKPlaceholderTextView()
    private let qrBtn  = UIButton.init(type: .custom)

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpSubViews()
    }

    func setUpSubViews() {

        textView.frame = CGRect(x: 15, y: 15, width: ScreenSize.width - 30, height: 105)
        textView.backgroundColor = .white
        textView.delegate = self
        textView.placeholderColor = ColorFromString(hex: "#989CAA")
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = ColorFromString(hex: "#E9EBF0").cgColor
        textView.clipsToBounds = true
        contentView.addSubview(textView)

        qrBtn.frame = CGRect(x: ScreenSize.width - 30 - 46, y: 105 - 46, width: 46, height: 46)
        qrBtn.setImage(UIImage.init(named: "qrCode"), for: .normal)
        qrBtn.addTarget(self, action: #selector(didClickQRButton), for: .touchUpInside)
        textView.addSubview(qrBtn)

    }

    func textViewDidChange(_ textView: UITextView) {
        delegate?.didGetTextViewText(text: textView.text)
    }

    @objc func didClickQRButton() {
        delegate?.didClickQRBtn()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
