//
//  DappViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore
import Toast_Swift
class DappViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UIScrollViewDelegate {
    private var webView = WKWebView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        didAddSubLayout()
    }

    func didAddSubLayout() {
        webView = WKWebView.init(frame: CGRect(x: 0, y: 20, width: ScreenSize.width, height: ScreenSize.height - 49 - 20))
//        let url = URL(string: "http://dapp.cryptape.com")
        let url = URL(string: "http://192.168.10.100:3000")
        let request = URLRequest.init(url: url!)

        var js = ""
        if let path = Bundle.main.path(forResource: "dappOpration", ofType: "js") {
            do {
                js += try String(contentsOfFile: path)
            } catch { }
        }
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        let infoDictionary = Bundle.main.infoDictionary!
        let majorVersion = infoDictionary["CFBundleShortVersionString"]
        webView.customUserAgent = "Neuron(Platform=iOS&AppVersion=\(String(describing: majorVersion!))"
        webView.configuration.userContentController.addUserScript(userScript)
        webView.configuration.preferences.javaScriptEnabled = true
        webView.configuration.userContentController.add(self, name: "getTitleBar")
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        webView.scrollView.bounces = false
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
        webView.load(request)
    }

    //scrollView代理
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

    //wkwebview
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            decisionHandler(.cancel)
            let browserViewController = UIStoryboard(name: "DAppBrowser", bundle: nil).instantiateViewController(withIdentifier: "browserViewController") as! BrowserViewController
            browserViewController.requestUrlStr = navigationAction.request.url?.absoluteString ?? ""
            self.navigationController?.pushViewController(browserViewController, animated: true)
            return
        }

        decisionHandler(.allow)
    }

    //WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "pushSearchView":
            let sCtrl = UIStoryboard(name: "DAppBrowser", bundle: nil).instantiateViewController(withIdentifier: "searchAppController")
            self.navigationController?.pushViewController(sCtrl, animated: true)
        default:
            break
        }
    }
}
