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
    private let textView = RSKPlaceholderTextView.init()
    private let qrBtn  = UIButton.init(type: .custom)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpSubViews()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpSubViews() {

        textView.frame = CGRect(x: 15, y: 15, width: ScreenW - 30, height: 105)
        textView.backgroundColor = ColorFromString(hex: "#f5f5f5")
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = ColorFromString(hex: "#eeeeee").cgColor
        textView.clipsToBounds = true
        contentView.addSubview(textView)

        qrBtn.frame = CGRect(x: ScreenW - 30 - 46, y: 105 - 46, width: 46, height: 46)
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
