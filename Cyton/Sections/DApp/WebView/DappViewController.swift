//
//  DappViewController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore
import Alamofire

/// DApp Home
class DappViewController: UIViewController, WKUIDelegate, ErrorOverlayPresentable {
    private let webView = WKWebView(frame: .zero)
    private var mainUrl = URL(string: "https://dapp.cryptape.com")!
    let netState = NetworkReachabilityManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "DApp.Home".localized()
        self.navigationItem.title = "ÐApp"

        addWebView()
        layoutWebView()

        errorOverlayRefreshBlock = { [weak self] () in
            guard let self = self else {
                return
            }
            self.removeOverlay()
            self.loadRequest()
        }

        loadRequest()
        monitorNetwork()
    }

    private func addWebView() {
        webView.customUserAgent = customUserAgent
        webView.configuration.userContentController.addUserScript(WKUserScript(source: injectedJavaScript, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        webView.configuration.preferences.javaScriptEnabled = true
        webView.configuration.userContentController.add(self, name: "pushSearchView")
        webView.configuration.userContentController.add(self, name: "pushMyDAppView")
        webView.configuration.userContentController.add(self, name: "pushCollectionView")
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false

        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        webView.uiDelegate = self

        view.addSubview(webView)
    }

    private func layoutWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func loadRequest() {
        var request = URLRequest(url: mainUrl)
        request.setAcceptLanguage()
        webView.load(request)
    }

    func monitorNetwork() {
        netState?.listener = { state in
            switch state {
            case .unknown, .notReachable:
                break
            case .reachable:
                self.removeOverlay()
                self.loadRequest()
                self.netState?.stopListening()
            }
        }
    }
}

// MARK: - User agent, JS, CSS style, etc.

private extension DappViewController {
    var injectedJavaScript: String {
        guard let path = Bundle.main.path(forResource: "dappOpration", ofType: "js") else {
            return ""
        }

        return (try? String(contentsOfFile: path)) ?? ""
    }

    var customUserAgent: String {
        let infoDictionary = Bundle.main.infoDictionary!
        let majorVersion = infoDictionary["CFBundleShortVersionString"]!
        return "Cyton(Platform=iOS&AppVersion=\(String(describing: majorVersion))"
    }

    var customStyle: String {
        let borderWidth = (100.0 / UIScreen.main.scale).rounded() / 100.0
        let borderColor = UITableView().separatorColor ?? UIColor(hex: "#CCCCCC")
        return """
        #id-page-home #id-container-dappblocks .dapp { border-bottom: \(borderWidth)px solid \(borderColor.hex); }
        """
    }
}

extension DappViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            decisionHandler(.cancel)
            let browserViewController: BrowserViewController = UIStoryboard(name: .dAppBrowser).instantiateViewController()
            browserViewController.requestUrlStr = navigationAction.request.url?.absoluteString ?? ""
            self.navigationController?.pushViewController(browserViewController, animated: true)
            return
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let error = error as NSError
        errorOverlaycontroller.style = .networkFail
        if error.code == -1009 {
            netState?.startListening()
            errorOverlaycontroller.messageLabel.text = "Common.Connection.LoseConnect".localized()
        } else {
            errorOverlaycontroller.messageLabel.text = "Common.Connection.LoadFaild".localized()
        }
        showOverlay()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        /// Inject custom CSS style
        webView.evaluateJavaScript("var style = document.createElement('style'); style.innerHTML = '\(customStyle)'; document.head.appendChild(style);")
    }
}

extension DappViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "pushSearchView":
            let searchAppController = UIStoryboard(name: "DAppBrowser", bundle: nil).instantiateViewController(withIdentifier: "searchAppController")
            self.navigationController?.pushViewController(searchAppController, animated: true)
        case "pushMyDAppView":
            let myDAppViewController: MyDAppViewController = UIStoryboard(name: .dAppBrowser).instantiateViewController()
            self.navigationController?.pushViewController(myDAppViewController, animated: true)
        case "pushCollectionView":
            let nftViewController = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "nftViewController")
            self.navigationController?.pushViewController(nftViewController, animated: true)
        default:
            break
        }
    }
}

// MARK: - Disable zooming

extension DappViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
