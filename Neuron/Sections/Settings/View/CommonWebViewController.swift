//
//  CommonWebViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/8.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import WebKit

class CommonWebViewController: UIViewController, WKNavigationDelegate {

    var urlStr = ""

    lazy private var webview: WKWebView = {
        self.webview = WKWebView.init(frame: CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height - 64))
        self.webview.navigationDelegate = self
        return self.webview
    }()

    lazy private var progressView: UIProgressView = {
        self.progressView = UIProgressView.init(frame: CGRect(x: 0, y: 0, width: ScreenSize.width, height: 2))
        self.progressView.tintColor = AppColor.themeColor
        self.progressView.trackTintColor = .white
        return self.progressView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webview)
        view.addSubview(progressView)
        webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webview.load(URLRequest.init(url: URL.init(string: urlStr)!))
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.alpha = 1.0
            progressView.setProgress(Float(webview.estimatedProgress), animated: true)
            if webview.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { (_) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
}
