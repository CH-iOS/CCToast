//
//  CCTableViewController.swift
//  CCToast
//
//  Created by chenh on 2020/10/15.
//

import UIKit

class CCTableViewController: UITableViewController {
    
    let dataArray = [
        "上, 文字",
        "中, 文字",
        "下, 文字",
        "中, 文字 + 图片",
        "中, 超长文字",
        "中, 点击事件",
        "默认",
        "只有图片",
        "上图下文字, 短文字",
        "上图下文字, 长文字",
        "富文本",
        "Y轴偏移50",
        "Hud, 1秒结束",
        "Hud超时回调",
        "Hud 自定义视图",
        "Hud 自定义动画数组"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "CCToast"
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ccCell")
        tableView.tableFooterView = UIView()
    
        let text = UITextView.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 30))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: text)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ccCell", for: indexPath)
        cell.textLabel?.text = dataArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            var style = CCToastStyle()
            style.position = .top
            CCToast.show("我是上Toast", style: style)
        case 1:
            CCToast.show("我是中Toast")
        case 2:
            var style = CCToastStyle()
            style.position = .bottom
            CCToast.show("我是下Toast", style: style)
        case 3:
            var style = CCToastStyle()
            style.imageSize = CGSize.init(width: 20, height: 20)
            CCToast.show("我是Toast + 图片", image: UIImage.init(named: "logo"),style: style)
        case 4:
            var style = CCToastStyle()
            style.messageMaxEdge = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
            CCToast.show("我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast我是超级Toast",style: style)
        case 5:
            CCToast.show("我是Toast + 图片 + 点击做事我是Toast + 图片 + 点击做事我是Toast + 图片 + 点击做事我是Toast + 图片 + 点击做事我是Toast + 图片 + 点击做事我是Toast + 图片 + 点击做事我是Toast + 图片 + 点击做事我是Toast + 图片 + 点击做事我是Toast + 图片 + 点击做事我是Toast + 图片 + 点击做事我是Toast + 图片 + 点击做事",image: UIImage.init(named: "logo")){ didTap in
                if didTap {
                    print("completion from tap")
                } else {
                    print("completion without tap")
                }
            }
        case 6:
            CCToast.show("默认Toast")
        case 7:
            var style = CCToastStyle()
            style.imagePosition = .top
            style.edge = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            style.imageSize = CGSize.init(width: 100, height: 100)
            CCToast.show("", image: UIImage.init(named: "logo"),style: style)
        case 8:
            var style = CCToastStyle()
            style.imagePosition = .top
            CCToast.show("Toast", image: UIImage.init(named: "logo"),style: style)
        case 9:
            var style = CCToastStyle()
            style.imagePosition = .top
            CCToast.show("我是ToastToastToastToast", image: UIImage.init(named: "logo"),style: style)
        case 10:
            let text = NSAttributedString(string: "AttributedString Toast", attributes: [NSAttributedString.Key.backgroundColor: UIColor.yellow])
            CCToast.show("我是富文本",attributedMessage: text)
        case 11:
            var style = CCToastStyle()
            style.position = .bottom
            style.verticalOffset = 10
            CCToast.show("哈哈哈哈", style: style) {(didTap) in
                if didTap {
                    print("completion from tap")
                } else {
                    print("completion without tap")
                }
            }
        case 12:
            var style = CCHudStyle()
            style.hudIndicatorColor = UIColor.ccGreen
            CCHud.show(dismissTime: 1.0, style: style)
        case 13:
            CCHud.show("我会超时回调...", dismissTime: 1.0) { (isTimeOut) in
                if isTimeOut {
                    print("超时要做的事")
                } else {
                    print("我被提前结束了")
                }
            }
        case 14:
            let view = UIView()
            view.backgroundColor = .red
            CCHud.show(animationView: view, dismissTime: 1.0)
        case 15:
            
            var array = Array<UIImage>()
            for i in 1..<12 {
                guard let image = UIImage.init(named: "ic_loading_small_\(i)") else {
                    return
                }
                array.append(image)
            }
            
            var style = CCHudStyle()
            style.animationViewSize = CGSize(width: 40, height: 40)
            style.edge = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
            CCHud.show("自定义动画...", animationImagesArray: array, dismissTime: 2,style: style)
            
        default:
            CCToast.show("我是Toast默认")
        }
    }
   
}
