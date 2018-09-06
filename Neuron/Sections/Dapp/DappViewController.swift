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
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        didAddSubLayout()
    }

    func didAddSubLayout() {
        webView = WKWebView.init(frame: CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height - 49))
        let url = URL(string: "http://47.97.171.140:8866")
        let request = URLRequest.init(url: url!)

        var js = ""
        if let path = Bundle.main.path(forResource: "dappOpration", ofType: "js") {
            do {
                js += try String(contentsOfFile: path)
            } catch { }
        }
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(userScript)
        webView.configuration.preferences.javaScriptEnabled = true
        webView.configuration.userContentController.add(self, name: "zhuru")
        webView.configuration.userContentController.add(self, name: "pushSearchView")
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

        let placrV = UIView.init()
        placrV.backgroundColor = AppColor.themeColor
        if isiphoneX() {
            placrV.frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: 44)
        } else {
            placrV.frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: 20)
        }
//        view.addSubview(placrV)
    }

    //scrollView代理
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

    //wkwebview
    //视图开始载入的时候显示网络活动指示器
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

    }

    //载入结束后，关闭网络活动指示器
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (_, _) in
//            print(html!)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    //阻止链接被点击
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            decisionHandler(.cancel)
            print(navigationAction.request.url!)

            return
        }

        decisionHandler(.allow)
    }

    //WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        print(message)
        print(message.body)
        switch message.name {
        case "pushSearchView":
            let sCtrl = SearchAppController.init(nibName: "SearchAppController", bundle: nil)
            self.navigationController?.pushViewController(sCtrl, animated: true)
        case "zhuru":
            print("这是注入的代码")
        default:

            break
        }
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let sCtrl = SearchAppController.init(nibName: "SearchAppController", bundle: nil)
//        self.navigationController?.pushViewController(sCtrl, animated: true)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
