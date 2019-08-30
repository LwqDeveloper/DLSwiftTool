//
//  AlertSheetView.swift
//  PlatformKit
//
//  Created by leefenghy on 2019/4/2.
//  Copyright © 2019 Fish. All rights reserved.
//

import UIKit

public class DLActionSheetView: UIView {

    private var containerView: UIView?
    
    private var list = [DLSheetModel]()
    // 声明一个闭包
    private var closure: (Int) ->() = {_ in }
    //
    private var tableView: UITableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        prepareUI()
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareUI() {
        self.frame = UIScreen.main.bounds
        self.clipsToBounds = true
        tableView.frame = CGRect(x: 0, y: self.bounds.height, width: self.bounds.size.width, height: 0)
        self.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DLSheetCell.self, forCellReuseIdentifier: "DLSheetCell")
        tableView.backgroundColor = UIColor.ColorHex(hex: "0x2A2A2D")
        tableView.frame = CGRect.zero
        tableView.separatorColor = UIColor.clear
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        
    }

    override public func draw(_ rect: CGRect) {
        let size = CGSize(width: 14, height: 14)
        let corners: UIRectCorner = [UIRectCorner.topLeft, UIRectCorner.topRight]
        let rectPath = UIBezierPath(roundedRect: self.tableView.bounds, byRoundingCorners: corners, cornerRadii: size)
        let rectLayer = CAShapeLayer()
        rectLayer.lineJoin = CAShapeLayerLineJoin.round;
        rectLayer.lineCap = CAShapeLayerLineCap.round;
        rectLayer.path = rectPath.cgPath;
        self.tableView.layer.mask = rectLayer
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss()
    }
    
    // MARK:弹出视图 --- 自定义
    func presentToContainer(_ container: UIView?, items: [DLSheetModel], closure: @escaping (Int) -> Void) {
        
        self.list = items
        self.closure = closure
        self.containerView = container
        if self.containerView == nil {
            self.containerView = UIApplication.shared.keyWindow
        }
        self.backgroundColor = UIColor.ColorHex(hex: "0x04040F", alpha: 0.0)
        self.containerView?.addSubview(self)
        let height: CGFloat = CGFloat(items.count * 56)
        self.tableView.frame = CGRect(x: 0, y: self.bounds.size.height, width: self.bounds.size.width, height: height)
        tableView.reloadData()
        self.layoutIfNeeded()
        
        UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: UIView.KeyframeAnimationOptions.calculationModeLinear, animations: {
            self.tableView.frame = CGRect(x: 0, y: self.bounds.size.height - height, width: self.bounds.size.width, height: height)
            self.backgroundColor = UIColor.ColorHex(hex: "0x04040F", alpha: 0.7)
            self.layoutIfNeeded()
        }) { (flag) in
            
        }
    }

    public func dismiss() {
        let frame = self.tableView.frame
        self.layoutIfNeeded()
        UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: UIView.KeyframeAnimationOptions.calculationModeLinear, animations: {
            self.backgroundColor = UIColor.ColorHex(hex: "0x04040F", alpha: 0.0)
            self.tableView.frame = CGRect(x: 0, y: self.bounds.size.height, width: self.bounds.size.width, height: frame.height)
            self.layoutIfNeeded()
        }) { (flag) in
            self.removeFromSuperview()
        }
    }

}

extension DLActionSheetView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DLSheetCell = tableView.dequeueReusableCell(withIdentifier: "DLSheetCell") as! DLSheetCell
        let model = self.list[indexPath.row]
        cell.titleLabel.font = model.font
        cell.titleLabel.text = model.title
        cell.titleLabel.textColor = model.textColor
        cell.sepLine.isHidden = indexPath.row < self.list.count - 1
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.closure(indexPath.row)
        self.dismiss()
    }
}

// MARK: - cell
class DLSheetCell: UITableViewCell {
    var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.textColor = UIColor.ColorHex(hex: "0xf9f9f9")
        label.textAlignment = .center
        return label
    }()
    
    var sepLine: UIView = {
        let view = UIView.init(frame: CGRect.zero)
        view.backgroundColor = UIColor.ColorHex(hex: "0x828282")
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.ColorHex(hex: "0x2a2a2d")
        contentView.addSubview(titleLabel)
        contentView.addSubview(sepLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = self.bounds
        sepLine.frame = CGRect.init(x: 0, y: self.bounds.size.height - 0.5, width: self.bounds.size.width, height: 0.5)
    }
}

// MARK: - Model
class DLSheetModel {
    var font: UIFont = UIFont.systemFont(ofSize: 16)
    var title: String = ""
    var textColor: UIColor = UIColor.ColorHex(hex: "0xF9F9F9")
}
