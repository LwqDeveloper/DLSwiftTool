//
//  AppNavgationBarView.swift
//  PlatformKit
//
//  Created by leefenghy on 2019/5/29.
//  Copyright © 2019 Fish. All rights reserved.
//

import UIKit

// 自定义事件
public protocol DLNavgationBarViewAble: NSObjectProtocol {
    func leftButtonTouchUpInside(_ sender: UIButton)
}
// MARK: 导航视图样式，pop或者present
public enum NavgationBarViewStyle: String {
    case pop = "pop"
    case present = "present"
    case custom = "custom"
    case none = "none"
}

typealias DLNavBarCompletion = (() -> Void)
// MARK: 自定义导航
open class DLNavgationBarView: UIView {

    // delegate
    public weak var delegate: DLNavgationBarViewAble?
    
    var style: NavgationBarViewStyle = .pop
    
    var leftColorTextCompletion: DLNavBarCompletion!
    var rightColorTextCompletion: DLNavBarCompletion!
    // title font
    public var titleFont: UIFont? {
        willSet {
            if let font = newValue {
                titleLabel.font = font
            }
        }
    }
    
    // title color
    public var titleColor: UIColor? {
        willSet {
            if let color = newValue {
                titleLabel.textColor = color
            }
        }
    }
    public var leftImage: UIImage? {
        willSet {
            if let image = newValue {
                self.leftButton.setImage(image, for: .normal)
            }
        }
    }
    // 设置标题
    public var title: String = "" {
        willSet {
            self.titleLabel.text = newValue
            let width = DLHelperString.widthForString(newValue, font: self.titleLabel.font)
            self.titleLabel.frame = CGRect(x: DLUtilsScreen.screenWidth/2 - width/2, y: 12, width: width, height: 20)
        }
    }
    public let statusBarView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.mainThemeColor()
        return view
    }()
    public let containerView: UIView = {
        let view = UIView.init()
        view.frame = CGRect(x: 0, y: 0, width: DLUtilsScreen.screenWidth, height: 44)
        view.backgroundColor = UIColor.mainThemeColor()
        return view
    }()
    
    public let leftButton: UIButton = {
        let backBtn = UIButton.init(type: .custom)
        backBtn.frame = CGRect(x: 10, y: 4, width: 36, height: 36)
        return backBtn
    }()
    
    public let titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    // MARK: 扩展导航右边视图
    // note: height isequal navgationBar height
    public let rightView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(statusBarView)
        self.addSubview(containerView)
        containerView.addSubview(leftButton)
        leftButton.setImage(UIImage(named: "icon_navbar_Chevron", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        leftButton.addTarget(self, action: #selector(leftButtonEvent(_:)), for: .touchUpInside)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(rightView)
    }
    
    public convenience init(style: NavgationBarViewStyle) {
        self.init()
        self.style = style
    }
    
    // leftButton 点击事件
    @objc func leftButtonEvent(_ sender: UIButton) {
        if self.style == .custom {
            self.delegate?.leftButtonTouchUpInside(sender)
        }else {
            let vc = self.getFirstViewController()
            if self.style == .pop {
                vc?.navigationController?.popViewController(animated: true)
            }else {
                vc?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()

        self.frame = CGRect(x: 0, y: 0, width: DLUtilsScreen.screenWidth, height: DLUtilsScreen.navigationHeight)
        
        self.statusBarView.frame = CGRect(x: 0, y: 0, width: DLUtilsScreen.screenWidth, height: DLUtilsScreen.statusBarHeight)
        self.containerView.frame = CGRect(x: 0, y: DLUtilsScreen.statusBarHeight, width: DLUtilsScreen.screenWidth, height: DLUtilsScreen.navigationBarHeight)
        
        if let text = titleLabel.text, text.count != 0 {
            let width = DLHelperString.widthForString(text, font: self.titleLabel.font)
            self.titleLabel.frame = CGRect(x: DLUtilsScreen.screenWidth/2 - width/2, y: 12, width: width, height: 20)
        }else {
            self.titleLabel.frame = CGRect.zero
        }
        
        // rightView
        var rightWidth: CGFloat = 0
        let rightMargin: CGFloat = 16
        for (_, subview) in self.rightView.subviews.enumerated() {
            rightWidth += subview.frame.width
        }
        self.rightView.frame = CGRect(x: DLUtilsScreen.screenWidth - (rightWidth + rightMargin), y: 0, width: rightWidth, height: DLUtilsScreen.navigationBarHeight)
        
        // leftButton
        if self.style == .pop {
            leftButton.setImage(UIImage(named: "icon_navbar_Chevron", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        }else if self.style == .present {
            leftButton.setImage(UIImage(named: "icon_navbar_close", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        }else if self.style == .custom {
            //leftButton.setImage(self.leftImage, for: .normal)
        }else {
            leftButton.isHidden = true
        }
        
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setLeftButtonImage(_ image: UIImage?) {
        self.leftButton.setImage(image, for: .normal)
    }
    
    func setLeftColorText(_ text: String,_ completion: @escaping DLNavBarCompletion) {
        let width = DLHelperString.widthForString(text, font: UIFont(name: "PingFangSC-Medium", size: 16)!) + 4
        self.setColorText(text, CGRect(x: 10, y: 4, width: width, height: 36), true)
        self.leftColorTextCompletion = completion
    }
    
    func setRightColorText(_ text: String,_ completion: @escaping DLNavBarCompletion) {
        let width = DLHelperString.widthForString(text, font: UIFont.systemFont(ofSize: 16)) + 4
        self.setColorText(text, CGRect(x: DLUtilsScreen.screenWidth - width - 10, y: 4, width: width, height: 36), false)
        self.rightColorTextCompletion = completion
    }
    
    func setColorText(_ text: String, _ textframe: CGRect, _ isLeft: Bool) {
//        let label = UILabel()
//        let attrString = NSMutableAttributedString(string: text)
//        label.frame = textframe
//        let shadow = NSShadow()
//        shadow.shadowColor = UIColor(red: 0, green: 0, blue: 0,alpha:0.2)
//        shadow.shadowBlurRadius = 4
//        shadow.shadowOffset = CGSize(width: 0, height: 2)
//        let attr: [NSAttributedString.Key : Any] = [.font: UIFont(name: "PingFangSC-Medium", size: 16) as Any,.foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1), .shadow: shadow]
//        attrString.addAttributes(attr, range: NSRange(location: 0, length: attrString.length))
//        label.attributedText = attrString
//        let gradientView = UIView(frame: label.bounds)
//        let gradient = CAGradientLayer()
//        gradient.colors = [UIColor(red: 0.95, green: 0.45, blue: 1, alpha: 1).cgColor, UIColor(red: 0.45, green: 0.4, blue: 1, alpha: 1).cgColor, UIColor(red: 0.25, green: 0.45, blue: 1, alpha: 1).cgColor, UIColor(red: 0.78, green: 0.96, blue: 0.35, alpha: 1).cgColor]
//        gradient.startPoint = CGPoint(x: 0.05561755952380952, y: 0.5)
//        gradient.endPoint = CGPoint(x: 0.9058965773809524, y: 0.5)
//        gradient.frame = label.frame
//        gradientView.layer.addSublayer(gradient)
//        gradientView.mask = label
//        self.containerView.addSubview(gradientView)
        
        let button = UIButton.init(type: .custom)
        button.frame = textframe
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.clear
        if isLeft {
            button.addTarget(self, action: #selector(leftColorTextTap), for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(rightColorTextTap), for: .touchUpInside)
        }
        self.containerView.addSubview(button)
    }
    
    @objc private func leftColorTextTap() {
        self.leftColorTextCompletion()
    }
    
    @objc private func rightColorTextTap() {
        self.rightColorTextCompletion()
    }
}
