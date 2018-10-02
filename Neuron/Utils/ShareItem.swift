//
//  ShareItem.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/25.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class ShareItem: NSObject, UIActivityItemSource {

    var shareString: String

    init(shareString: String) {
        self.shareString = shareString
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return shareString
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return shareString
    }

}
