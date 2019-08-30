//
//  ViewController.swift
//  DLSwiftTool
//
//  Created by user on 2019/8/30.
//  Copyright © 2019 muyang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let navBar: DLNavgationBarView = {
        let view = DLNavgationBarView.init(style: .custom)
        view.title = "DLSwiftTool"
        view.leftButton.isHidden = true
        return view
    }()
    
    var sheetButton: UIButton!
    var sheetView: DLActionSheetView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
    }

    func setupUI() {
        view.addSubview(navBar)
        
        sheetButton = UIButton.init(type: .custom)
        sheetButton.frame = CGRect.init(x: 16, y: 150, width: DLUtilsScreen.screenWidth - 32, height: 50)
        sheetButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        sheetButton.setCornerRadius(5)
        sheetButton.setTitle("Sheet", for: .normal)
        sheetButton.setTitleColor(UIColor.white, for: .normal)
        sheetButton.backgroundColor = UIColor.orange
        sheetButton.addTarget(self, action: #selector(sheetButtonClick), for: .touchUpInside)
        view.addSubview(sheetButton)
        sheetView = DLActionSheetView.init()
    }
    
    @objc func sheetButtonClick() {
        let titles = ["举报", "拉黑", "取消"]
        let colors = [UIColor.ColorHex(hex: "0xF9F9F9"), UIColor.ColorHex(hex: "0xF9F9F9"), UIColor.red]
        var models = [DLSheetModel]()
        for i in 0..<titles.count {
            let model = DLSheetModel.init()
            model.title = titles[i]
            model.textColor = colors[i]
            models.append(model)
        }
        sheetView.presentToContainer(view, items: models) { (index) in
            print(index)
        }

    }
}

