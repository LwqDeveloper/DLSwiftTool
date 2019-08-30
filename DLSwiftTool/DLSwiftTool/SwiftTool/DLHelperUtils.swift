//
//  HelperUtils.swift
//  LoveWords
//
//  Created by user on 2019/8/2.
//  Copyright © 2019 muyang. All rights reserved.
//

import Foundation
import UIKit

public struct DLUtilsApp {
    // MARK: 由于通过framework获取的bBundle.main不是本framework路径，以下信息不准
    /// APP名称
    public static let AppName: String = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
    
    /// APP版本
    public static let AppVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    
    /// APP版本号
    public static let AppBuild: String = Bundle.main.infoDictionary!["CFBundleVersiond"] as! String
    
    ///  bundle id
    public static let BundleID: String = Bundle.main.bundleIdentifier!
    
}

public struct DLUtilsDevice {
    /// iOS版本号
    public static let iOSVersion: String = UIDevice.current.systemVersion
    
    /// 设备类型
    public static let phoneModel: String = UIDevice.current.name
    
    public static func getUUIDString() -> String {
        let uuidRef = CFUUIDCreate(kCFAllocatorDefault)
        let strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef)
        let uuidString = (strRef! as String).replacingOccurrences(of: "-", with: "")
        return uuidString
    }
    
}

public struct DLUtilsScreen {
    /// frame
    public static let screenHeight:CGFloat = UIScreen.main.bounds.size.height
    public static let screenWidth:CGFloat = UIScreen.main.bounds.size.width
    public static let screenMaxLength:CGFloat = max(screenHeight, screenWidth)
    public static let screenMinLength:CGFloat = max(screenWidth, screenHeight)
    public static let navigationBarHeight: CGFloat = 44
    /// 一像素。
    public static let pixelOne : CGFloat = 1 / UIScreen.main.scale
    
    /// 状态栏高度。
    public static let statusBarHeight:CGFloat = UIApplication.shared.statusBarFrame.height
    public static var navigationHeight: CGFloat {
        return statusBarHeight + navigationBarHeight
    }
    
    ///
    public static var tabbarSafeBottomMargin: CGFloat {
        if UIDevice.isIPHONE_X {
            return 34.0
        }
        return 0
    }
    
    public static let SCREANSCALEWIDTH = UIScreen.main.bounds.size.width / 375.0
    public static let SCREANSCALEHEIGHT = UIScreen.main.bounds.size.height / 812
    /// 高宽比
    public static var heightScaleWidth: CGFloat {
        return screenHeight / screenWidth
    }
    
    public func scaleHeight(_ height:CGFloat) -> CGFloat {
        return height * DLUtilsScreen.SCREANSCALEHEIGHT
    }
    
    public func scaleWidth(_ width:CGFloat) -> CGFloat {
        return width * DLUtilsScreen.SCREANSCALEWIDTH
    }
    
}


public extension UIDevice {
    /// 是否为模拟器
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
        isSim = true
        #endif
        return isSim
    }()
    
    static var isIpad: Bool {
        return UIDevice.current.model.hasPrefix("iPad")
    }
    
    static var isRETIAN_3_5: Bool {
        return UIScreen.instancesRespond(to: #selector(getter: UIDynamicItem.bounds)) ? CGSize(width: 320, height: 480).equalTo(UIScreen.main.bounds.size) : false
    }
    
    static var isRETIAN_4_0: Bool {
        return UIScreen.instancesRespond(to: #selector(getter: UIDynamicItem.bounds)) ? CGSize(width: 320, height: 568).equalTo(UIScreen.main.bounds.size) : false
    }
    
    static var isIPHONE_4_7: Bool {
        return UIScreen.instancesRespond(to: #selector(getter: UIDynamicItem.bounds)) ? CGSize(width: 375, height: 667).equalTo(UIScreen.main.bounds.size) : false
    }
    
    static var isIPHONE_5_5: Bool {
        return UIScreen.instancesRespond(to: #selector(getter: UIDynamicItem.bounds)) ? CGSize(width: 414, height: 736).equalTo(UIScreen.main.bounds.size) : false
    }
    
    static var isIPHONE_X: Bool {
        let screenSize = UIScreen.main.bounds.size
        if  screenSize.height / screenSize.width > 2.0{
            return true
        }
        return false
    }
    
}

/// GCD延时操作
///   - after: 延迟的时间
///   - handler: 事件
public func DLDispatchAfter(after: Double, handler:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + after) {
        handler()
    }
}

/// GCD定时器倒计时⏳
///   - timeInterval: 循环间隔时间
///   - repeatCount: 重复次数
///   - handler: 循环事件, 闭包参数： 1. timer， 2. 剩余执行次数
public func DLDispatchTimer(timeInterval: Double, repeatCount:Int, handler:@escaping (DispatchSourceTimer?, Int)->())
{
    if repeatCount <= 0 {
        return
    }
    let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    var count = repeatCount
    timer.schedule(wallDeadline: .now(), repeating: timeInterval)
    timer.setEventHandler(handler: {
        count -= 1
        DispatchQueue.main.async {
            handler(timer, count)
        }
        if count == 0 {
            timer.cancel()
        }
    })
    timer.resume()
}

/// GCD定时器循环操作
///   - timeInterval: 循环间隔时间
///   - handler: 循环事件
public func DLDispatchTimer(timeInterval: Double, handler:@escaping (DispatchSourceTimer?)->())
{
    let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    timer.schedule(deadline: .now(), repeating: timeInterval)
    timer.setEventHandler {
        DispatchQueue.main.async {
            handler(timer)
        }
    }
    timer.resume()
}

/// 打印
public func DLDPrint<T>(_ message : T?, file : String = #file, funcName : String = #function, lineNum : Int = #line) {
    
    #if DEBUG
    // 获取文件名
    let fileName = (file as NSString).lastPathComponent.components(separatedBy: ".")[0]
    let msg: Any = message ?? ""
    let str: NSString = "\n[\(fileName) \(funcName)](\(lineNum)): \(msg)\n" as NSString
    print("\n")
    NSLog("%@", str)
    #endif
}

extension UIView {
    // MARK: 获取view最顶层的viewController
    // 关系为：UIWindow->ViewController.View->ViewA - - ->用户点击的View
    // 而获取View所在的ViewController是上面的逆序操作，关系为：view->superView->ViewController->UIWindow->UIApplication->UIDelegete->nil。
    public func getFirstViewController() -> UIViewController? {
        for view in sequence(first: self.superview, next: {$0?.superview}) {
            if let responder = view?.next{
                if responder.isKind(of: UIViewController.self){
                    return responder as? UIViewController
                }
            }
        }
        return nil
    }
    
    // MARK: set view cornerRadius
    public func setCornerRadius(_ cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
    // MARK: set view borderColor and borderWidth
    public func setBorder(_ color: UIColor, width: CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
}
