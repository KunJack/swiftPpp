//
//  BrowserManager.swift
//

import Foundation
import UIKit

class BrowserManager : NSObject {
    
    typealias BrowserMenuCallback = (Int) -> Void
    typealias BrowserCallback = () -> Void
    
    @objc static let shareManager = BrowserManager()
    
    @objc var url:String?
    @objc var html:String?
    @objc var title:String?
    @objc var requst:URLRequest?
    @objc var progressBackgroundColor = UIColor.clear
    @objc var progressColor = UIColor.black
    @objc var customerBackBtn:UIBarButtonItem?
    @objc var customerCloseBtn:UIBarButtonItem?
    @objc var customerMoreBtn:UIBarButtonItem?
    @objc var isShowMoreBtn:Bool = true
    @objc var moreMemuList:[String]?
    @objc var moreMemuCallBackList:BrowserMenuCallback?
    
    @objc var onBack: BrowserCallback?
    
    private override init() {
        super.init()
        
    }
    
    @objc func open(){
        self.openBrowser()
    }
    
    
    func openBrowser() {
        let brower = BrowerController()
        if let navi = self.topViewController().navigationController {
            navi.pushViewController(brower, animated: true)
        }else{
            self.topViewController().present(UINavigationController.init(rootViewController: brower), animated: true, completion: nil)
        }
    }
    
    func topViewController() -> UIViewController{
        var resultVc = self .findTopViewController((UIApplication.shared.keyWindow?.rootViewController)!)
        while let realVc = resultVc.presentedViewController {
            resultVc = self.findTopViewController(realVc)
        }
        return resultVc
    }
    
    func findTopViewController(_ vc:UIViewController) -> UIViewController {
        if vc.isKind(of: UINavigationController.self) {
            return self.findTopViewController((vc as! UINavigationController).topViewController!)
        }else if vc.isKind(of: UITabBarController.self){
            return self.findTopViewController((vc as! UITabBarController).selectedViewController!)
        }else{
            return vc
        }
    }
    
    
}




