//
//  HelperColor.swift
//  LoveWords
//
//  Created by user on 2019/8/4.
//  Copyright © 2019 muyang. All rights reserved.
//

import UIKit

extension UIColor {
    
    public class func ColorHex(hex: String, alpha: CGFloat = 1.0) -> UIColor {
        return proceesHex(hex: hex, alpha: alpha)
    }
    
    public class func mainThemeColor() -> UIColor {
        return UIColor.ColorHex(hex: "0x292929")
    }
    
    public class func mainBgColor() -> UIColor {
        return UIColor.ColorHex(hex: "0x27262b").withAlphaComponent(0.9)
    }
    
    public class func lineColor() -> UIColor {
        return UIColor.ColorHex(hex: "0xeeeeee")
    }
    
    public class func textColorHeavy() -> UIColor {
        return UIColor.ColorHex(hex: "0x333333")
    }

    public class func textColorMedium() -> UIColor {
        return UIColor.ColorHex(hex: "0x666666")
    }

    public class func textColorLight() -> UIColor {
        return UIColor.ColorHex(hex: "0x999999")
    }
}

private func proceesHex(hex: String, alpha: CGFloat) -> UIColor{
    /** 如果传入的字符串为空 */
    if hex.isEmpty {
        return UIColor.clear
    }
    
    /** 传进来的值。 去掉了可能包含的空格、特殊字符， 并且全部转换为大写 */
    var hHex = (hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)).uppercased()
    
    /** 如果处理过后的字符串少于6位 */
    if hHex.count < 6 {
        return UIColor.clear
    }
    
    /** 开头是用0x开始的 */
    if hHex.hasPrefix("0X") {
        hHex = (hHex as NSString).substring(from: 2)
    }
    /** 开头是以＃开头的 */
    if hHex.hasPrefix("#") {
        hHex = (hHex as NSString).substring(from: 1)
    }
    /** 开头是以＃＃开始的 */
    if hHex.hasPrefix("##") {
        hHex = (hHex as NSString).substring(from: 2)
    }
    
    /** 截取出来的有效长度是6位， 所以不是6位的直接返回 */
    if hHex.count != 6 {
        return UIColor.clear
    }
    
    /** R G B */
    var range = NSMakeRange(0, 2)
    
    /** R */
    let rHex = (hHex as NSString).substring(with: range)
    
    /** G */
    range.location = 2
    let gHex = (hHex as NSString).substring(with: range)
    
    /** B */
    range.location = 4
    let bHex = (hHex as NSString).substring(with: range)
    
    /** 类型转换 */
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    
    Scanner(string: rHex).scanHexInt32(&r)
    Scanner(string: gHex).scanHexInt32(&g)
    Scanner(string: bHex).scanHexInt32(&b)
    
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
}

