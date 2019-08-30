//
//  HelperString.swift
//  LoveWords
//
//  Created by user on 2019/8/2.
//  Copyright © 2019 muyang. All rights reserved.
//

import Foundation
import UIKit

extension String {
    public func ranges(of string: String) -> [Range<String.Index>] {
        var rangeArray = [Range<String.Index>]()
        var searchedRange: Range<String.Index>
        guard let sr = self.range(of: self) else {
            return rangeArray
        }
        searchedRange = sr
        // 区分大小写搜索比较
        var resultRange = self.range(of: string, options: .literal, range: searchedRange, locale: nil)
        while let range = resultRange {
            rangeArray.append(range)
            searchedRange = Range(uncheckedBounds: (range.upperBound, searchedRange.upperBound))
            resultRange = self.range(of: string, options: .regularExpression, range: searchedRange, locale: nil)
        }
        return rangeArray
    }
    
    public func nsrange(fromRange range : Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    public func nsranges(of string: String) -> [NSRange] {
        return ranges(of: string).map { (range) -> NSRange in
            self.nsrange(fromRange: range)
        }
    }
    
    // 返回attributeString ---  防止重名
    public func attributeStringFrom(text: String, ofString: String, value: [NSAttributedString.Key : Any]) -> NSMutableAttributedString {
        let string: String = text
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
        let range = attributedString.string.ranges(of: ofString)
        if let ofrange = range.last {
            let nsrange = attributedString.string.nsrange(fromRange: ofrange)
            attributedString.addAttributes(value, range: nsrange)
        }
        return attributedString
    }
    
    // 返回attributeString ---  取第一个位置的attributeText
    public func first_attributeStringFrom(text: String, ofString: String, value:[NSAttributedString.Key : Any]) -> NSMutableAttributedString {
        let string: String = text
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
        let range = attributedString.string.range(of: ofString)
        if let ofrange = range{
            let nsrange = attributedString.string.nsrange(fromRange: ofrange)
            attributedString.addAttributes(value, range: nsrange)
        }
        return attributedString
    }
    
    func boundingRect(with constrainedSize: CGSize, font: UIFont, lineSpacing: CGFloat? = nil) -> CGSize {
        let attritube = NSMutableAttributedString(string: self)
        let range = NSRange(location: 0, length: attritube.length)
        attritube.addAttributes([NSAttributedString.Key.font: font], range: range)
        if lineSpacing != nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing!
            attritube.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        }
        
        let rect = attritube.boundingRect(with: constrainedSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        var size = rect.size
        
        if let currentLineSpacing = lineSpacing {
            // 文本的高度减去字体高度小于等于行间距，判断为当前只有1行
            let spacing = size.height - font.lineHeight
            if spacing <= currentLineSpacing && spacing > 0 {
                size = CGSize(width: size.width, height: font.lineHeight)
            }
        }
        
        return size
    }
    
    public func boundingRect(with constrainedSize: CGSize, font: UIFont, lineSpacing: CGFloat? = nil, lines: Int) -> CGSize {
        if lines < 0 {
            return .zero
        }
        
        let size = boundingRect(with: constrainedSize, font: font, lineSpacing: lineSpacing)
        if lines == 0 {
            return size
        }
        
        let currentLineSpacing = (lineSpacing == nil) ? (font.lineHeight - font.pointSize) : lineSpacing!
        let maximumHeight = font.lineHeight*CGFloat(lines) + currentLineSpacing*CGFloat(lines - 1)
        if size.height >= maximumHeight {
            return CGSize(width: size.width, height: maximumHeight)
        }
        
        return size
    }
    
    // seconds-> 时分秒
    public static func secondsToHHMMSS(_ seconds: Int) -> String {
        let hour: Int = Int(seconds/3600)
        let minute: Int = Int((seconds%3600)/60)
        let second: Int = Int(seconds%60)
        return String(format: "%.2d:%.2d:%.2d", hour,minute,second)
    }
    
    // seconds-> 分秒
    public static func secondsToMMSS(_ seconds: Int) -> String {
        let minute: Int = Int(seconds/60)
        let second: Int = Int(seconds%60)
        return String(format: "%.2d:%.2d", minute,second)
    }
    
    // 数字转换为万为单位或者小于10000返回本身
    public static func digitToString(_ digit: Int64) -> String {
        guard digit > 10000 else {
            if digit <= 0 {return ""}
            return String(format: "%ld", digit)
        }
        let myriabit: Int = Int(digit/10000)
        let kilobit: Int = Int((digit - Int64(myriabit * 10000))/1000)
        return String(format: "%d.%dw", myriabit,kilobit).lowercased()
    }
    
    // 数字转换为大写W为单位小于10000返回本身
    public static func digitToStringUppercased(_ digit: Int64) -> String {
        return String.digitToString(digit).uppercased()
    }
    
    /// MARK: 比较两个版本号的大小
    /// - parameter newVersion 新版本号-网络版本号
    /// - parameter oldVersion 本地版本号
    /// - return 版本号相等返回0; newVersion小于oldVersion返回-1; 否则返回1.
    public static func compareVersion(_ newVersion: String, oldVersion: String) -> Int {
        // 都为空，相等，返回0
        if newVersion.count == 0 && oldVersion.count == 0 {
            return 0
        }
        // newVersion为空，oldVersion不为空，返回-1
        if newVersion.count == 0 && oldVersion.count != 0 {
            return -1
        }
        // oldVersion为空，newVersion不为空，返回1
        if oldVersion.count == 0 && newVersion.count != 0 {
            return 1
        }
        
        // 获取版本号数组
        let array1 = newVersion.components(separatedBy: ".")
        let array2 = oldVersion.components(separatedBy: ".")
        
        // 取字段最少的，进行循环比较
        let smallCount = array1.count > array2.count ? array2.count : array1.count
        
        for i in 0..<smallCount {
            let value1 = array1[i]
            let value2 = array2[i]
            let result = value1.compare(value2)
            // 升序
            if result == .orderedAscending {
                return -1
            }
            // 降序
            if result == .orderedDescending {
                return 1
            }
        }
        
        if array1.count > array2.count {
            return 1
        }else if array1.count < array2.count {
            return -1
        }
        return 0
    }
}

public struct DLHelperString {
    /// 计算字符高度
    public static func heightForString(_ text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    /// 计算字符长度
    public static func widthForString(_ text: String, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: UIScreen.main.bounds.size.width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.width
    }
    
    /// 计算字符size
    public static func sizeForString(_ text: String, maxWidth: CGFloat, font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.size
    }
}
