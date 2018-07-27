//
//  BrowerController.swift
//

import UIKit
import WebKit

class BrowerController: UIViewController {

    lazy var backBtn: UIBarButtonItem = {
        if let barButton = BrowserManager.shareManager.customerBackBtn{
            return barButton
        }else{
            let barButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(BrowerController.back))
            return barButton
        }
    }()
    lazy var closeBtn: UIBarButtonItem = {
        if let close = BrowserManager.shareManager.customerCloseBtn{
            return close
        }else{
            let close = UIBarButtonItem(title: "关闭", style: .done, target: self, action: #selector(BrowerController.close))
            return close
        }
    }()
    lazy var moreBtn: UIBarButtonItem? = {
        if let more = BrowserManager.shareManager.customerCloseBtn{
            return more
        }else{
            let morelist = BrowserManager.shareManager.moreMemuList?.count ?? 0
            if morelist > 0{
                let more = UIBarButtonItem(title: "更多", style: .done, target: self, action: #selector(BrowerController.more))
                return more
            }
            return nil
        }
    }()
    
    let webview:WKWebView = WKWebView()
    let progress: UIProgressView = UIProgressView(frame: CGRect(x: 0.0, y: 0.0, width:UIScreen.main.bounds.size.width , height: 2.0))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.progress)
        self.progress.backgroundColor = BrowserManager.shareManager.progressBackgroundColor
        self.progress.tintColor = BrowserManager.shareManager.progressColor
        self.view.addSubview(self.progress)
        
        self.view.addSubview(self.webview)
        self.webview.frame = self.view.frame
        self.webview.uiDelegate = self
        self.webview.navigationDelegate = self
        
        if let url = BrowserManager.shareManager.url {
            self.webview.load(URLRequest(url: URL(string: url)!))
        }else if let html = BrowserManager.shareManager.html {
            self.webview.loadHTMLString(html, baseURL: nil)
        }else if let request = BrowserManager.shareManager.requst {
            self.webview.load(request)
        }
         
        self.webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTopBtnStatus()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if let title = BrowserManager.shareManager.title{
            self.title = title
        }else{
            self.title = BrowserManager.shareManager.url
        }

    }
    
    func updateTopBtnStatus() {
        if let moreBtn = self.moreBtn {
            self.navigationItem.rightBarButtonItem = moreBtn
        }
        if self.webview.canGoBack {
            self.navigationItem.leftBarButtonItems = [self.backBtn,self.closeBtn]
        }else{
            self.navigationItem.leftBarButtonItems = [self.backBtn]
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progress.progress = Float(self.webview.estimatedProgress)
            if self.progress.progress == 1.0 {
                UIView.animate(withDuration: 0.25,
                               delay: 0.3,
                               options: .curveEaseOut,
                               animations: {
                                self.progress.transform = CGAffineTransform(scaleX: 1.0, y: 1.4)
                }, completion: { (finished) in
                    self.progress.isHidden = true
                })
            }
        }
    }
    
    @objc private func more() {
        let moreListCount = BrowserManager.shareManager.moreMemuList?.count ?? 0
        if moreListCount > 0  {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let list = BrowserManager.shareManager.moreMemuList ?? []
            for (index,actionTitle) in list.enumerated() {
                let action = UIAlertAction(title: actionTitle,
                                           style: .default,
                                           handler: { (action) in
                                            if let menuCallback = BrowserManager.shareManager.moreMemuCallBackList{
                                                menuCallback(index)
                                            }
                })
                actionSheet.addAction(action)
            }
            self.present(actionSheet, animated: true, completion: nil)
        }
        
        
    }
    
    @objc private func back() {
        if self.webview.canGoBack {
            self.webview.goBack()
        }else{
            self.close()
        }
    }
    
    @objc private func close() {
        let vcCount = self.navigationController?.viewControllers.count ?? 0
        if vcCount <= 1{
            self.navigationController?.dismiss(animated: true, completion: {
            })
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BrowerController: WKUIDelegate{
    
    // new webview
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return WKWebView()
    }
    
    // input
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        completionHandler("QAQ")
    }
    
    // confirm
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
}

extension BrowerController: WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.view.bringSubview(toFront: self.progress)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.updateTopBtnStatus()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.progress.sendSubview(toBack: self.progress)
        self.updateTopBtnStatus()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.updateTopBtnStatus()
        self.progress.sendSubview(toBack: self.progress)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
}





