//
//  CCHud.swift
//  CCToast
//
//  Created by chenh on 2020/10/22.
//

import UIKit

public class CCHud: UIView {
    
    var style: CCHudStyle = CCHudManager.shared.style
    
    var completion: ((Bool) -> Void)?
    
    var message : String?
    
    var dismissTime: TimeInterval = CCHudManager.shared.style.dismissTime
    
    var animationView = UIView()
    
    public lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.numberOfLines = style.messageNumberOfLines
        messageLabel.font = style.messageFont
        messageLabel.textColor = style.messageColor
        messageLabel.lineBreakMode = .byTruncatingTail
        messageLabel.backgroundColor = UIColor.clear
        return messageLabel
    }()
    
    lazy var hudView: UIView = {
        let hudView = UIView()
        hudView.backgroundColor = style.backgroundColor
        hudView.layer.cornerRadius = style.cornerRadius
        hudView.clipsToBounds = true
        return hudView
    }()
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: style.animationViewSize.width, height: style.animationViewSize.height)
        activityIndicatorView.color = style.hudIndicatorColor
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }()
    
    public init(_ message: String?,
                animationView: UIView? = nil,
                animationImagesArray: Array<UIImage>? = nil,
                animationDuration : TimeInterval = CCHudManager.shared.style.animationDuration,
                dismissTime: TimeInterval = CCHudManager.shared.style.dismissTime,
                style: CCHudStyle = CCHudManager.shared.style,
                completion: ((_ isTimeOut: Bool) -> Void)? = nil
    ) {
        super.init(frame: .zero)
        self.style = style
        self.completion = completion
        self.message = message
        self.dismissTime = dismissTime
        self.isUserInteractionEnabled = style.isUserInteractionEnabled
        self.addSubview(self.hudView)
        
        let addMessage = {
            if (message != nil) {
                self.messageLabel.text = message
                self.hudView.addSubview(self.messageLabel)
            }
        }
        
        if  animationImagesArray == nil, animationView == nil {
            self.animationView = self.activityIndicatorView
            self.hudView.addSubview(self.animationView)
            addMessage()
            return
        }
        
        if animationView != nil  {
            self.animationView = animationView!
            self.hudView.addSubview(self.animationView)
            addMessage()
            return
        }
        
        if  animationImagesArray != nil {
            let animationView = UIImageView()
            animationView.animationImages = animationImagesArray
            animationView.animationDuration = animationDuration
            animationView.startAnimating()
            self.animationView = animationView
            self.hudView.addSubview(self.animationView)
            addMessage()
            return
        }
    }
    
    public func becomeActive() {
        self.alpha = 0
        UIView.animate(withDuration: CCHudManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.alpha = 1.0
        })
        CCHudManager.shared.activeCCHud = self
        
        guard self.dismissTime > 0 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + self.dismissTime) {
            if let ylHud =  CCHudManager.shared.activeCCHud {
                ylHud.hide()
                self.completion?(true)
            }else {
                self.completion?(false)
            }
        }
    }
    
    public func hide() {
        CCHudManager.shared.activeCCHud = nil
        UIView.animate(withDuration: CCHudManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            self.alpha = 0.0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        hudView.frame = CGRect.init(x: 0, y: 0,
                                    width: style.animationViewSize.width + style.edge.left + style.edge.right,
                                    height: style.animationViewSize.height + style.edge.top + style.edge.bottom)
        hudView.center = CGPoint.init(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        self.animationView.frame.size = style.animationViewSize
        self.animationView.center = CGPoint(x: hudView.bounds.size.width / 2.0, y: hudView.bounds.size.height / 2.0)
        
        guard message != nil else { return }
        
        let safeAreaInsets = UIApplication.shared.delegate?.window??.safeAreaInsets
        let safeTop = safeAreaInsets?.top ?? 0.0
        let safeRight = safeAreaInsets?.right ?? 0.0
        let safeBottom = safeAreaInsets?.bottom ?? 0.0
        let safeLeft = safeAreaInsets?.right ?? 0.0
        let maxMessageSize = CGSize(
            width:
                UIScreen.main.bounds.width -
                style.messageMaxEdge.left -
                style.messageMaxEdge.right -
                safeRight - safeLeft,
            height: UIScreen.main.bounds.height
                - style.messageMaxEdge.top -
                style.messageMaxEdge.bottom -
                safeBottom - safeTop
        )
    
        let messageSize = self.messageLabel.sizeThatFits(maxMessageSize)
        let actualWidth = min(messageSize.width, maxMessageSize.width)
        let actualHeight = min(messageSize.height, maxMessageSize.height)
    
        var messageRect = CGRect.zero
        messageRect.origin.x = style.edge.left
        messageRect.origin.y = style.edge.top +
            self.animationView.bounds.size.height + style.edge.top
        messageRect.size.width = actualWidth
        messageRect.size.height = actualHeight
        
        self.messageLabel.frame = messageRect
        
        hudView.frame = CGRect(x: 0, y: 0, width: messageRect.size.width + style.edge.left + style.edge.right, height: messageRect.maxY + style.edge.bottom)
        hudView.center = CGPoint.init(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        self.animationView.center = CGPoint(x: hudView.bounds.size.width / 2.0, y: style.edge.top + style.animationViewSize.height / 2.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public class func show(
        _ message: String? = nil,
        dismissTime: TimeInterval = CCHudManager.shared.style.dismissTime,
        style: CCHudStyle = CCHudManager.shared.style,
        completion: ((_ isTimeOut: Bool) -> Void)? = nil
    ) -> CCHud {
        let hudView = CCHud.init(
            message,
            dismissTime: dismissTime,
            style: style,
            completion: completion
        )
        hudView.becomeActive()
        UIApplication.shared.windows.first?.addSubview(hudView)
        return hudView
    }
    
    @discardableResult
    public class func show(
        _ message: String? = nil,
        animationView: UIView,
        dismissTime: TimeInterval = CCHudManager.shared.style.dismissTime,
        style: CCHudStyle = CCHudManager.shared.style,
        completion: ((_ isTimeOut: Bool) -> Void)? = nil
    ) -> CCHud {
        let hudView = CCHud.init(
            message,
            animationView: animationView,
            dismissTime: dismissTime,
            style: style,
            completion: completion
        )
        hudView.becomeActive()
        UIApplication.shared.windows.first?.addSubview(hudView)
        return hudView
    }
    
    @discardableResult
    public class func show(
        _ message: String? = nil,
        animationImagesArray: Array<UIImage>,
        animationDuration : TimeInterval = CCHudManager.shared.style.animationDuration,
        dismissTime: TimeInterval = CCHudManager.shared.style.dismissTime,
        style: CCHudStyle = CCHudManager.shared.style,
        completion: ((_ isTimeOut: Bool) -> Void)? = nil
    ) -> CCHud {
        let hudView = CCHud.init(
            message,
            animationImagesArray: animationImagesArray,
            animationDuration: animationDuration,
            dismissTime: dismissTime,
            style: style,
            completion: completion
        )
        hudView.becomeActive()
        UIApplication.shared.windows.first?.addSubview(hudView)
        return hudView
    }
    
    public class func dismiss() {
        if let ylhudView = CCHudManager.shared.activeCCHud {
            ylhudView.hide()
        }
    }
}

public extension UIView {
    
    @discardableResult
    func makeYLHud(
        _ message: String? = nil,
        dismissTime: TimeInterval = CCHudManager.shared.style.dismissTime,
        style: CCHudStyle = CCHudManager.shared.style,
        completion: ((_ isTimeOut: Bool) -> Void)? = nil
    ) -> CCHud {
        let hudView = CCHud.init(
            message,
            dismissTime: dismissTime,
            style: style,
            completion: completion
        )
        hudView.becomeActive()
        self.addSubview(hudView)
        return hudView
    }
    
    func hideYLHud() {
        if let ylhudView = CCHudManager.shared.activeCCHud {
            ylhudView.hide()
        }
    }
}

public struct CCHudStyle {
    
    /**
     Hud backgroundColor. Default is `.black` at 80% opacity.
     */
    public var backgroundColor = UIColor.black.withAlphaComponent(0.8)
    
    /**
     If  hud is not removed after this dismissTime, callback will be executed. Default is `0.0`
     `0.0` 0, means it undisappear
     */
    public var dismissTime : TimeInterval = 0.0
    
    /**
     Hud cornerRadius. Default is `5.0`
     */
    public var cornerRadius: CGFloat = 5.0
    
    /**
     Hud message Color .Default is `.white`.
     */
    public var messageColor = UIColor.white
    
    /**
     The maximum hud distance from the screen margin.  Default is `(top: 30, left: 30, bottom: 30, right: 30)`.
     */
    public var messageMaxEdge = UIEdgeInsets.init(top: 30, left: 30, bottom: 30, right: 30)
    
    /**
     Hud edge .Default is `(top: 10, left: 10, bottom: 10, right: 10)`.
     */
    public var edge = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
    
    /**
     Hud messageFont. Default is `16.0`.
     */
    public var messageFont = UIFont.systemFont(ofSize: 16.0)
    
    /**
     Hud messageNumberOfLines. Default is `0`.
     */
    public var messageNumberOfLines = 0
    
    /**
     Hud  fade in/out animation duration. Default is `0.2`.
     */
    public var fadeDuration: TimeInterval = 0.2
    
    /**
     Hud  hudIndicatorColor. Default is `.white`
     */
    public var hudIndicatorColor: UIColor = .white
    
    /**
     Hud  isUserInteractionEnabled. Default is `.true`
     */
    public var isUserInteractionEnabled :Bool = true
    
    /**
     Hud  custom animation duration . Default is `1.0`
     */
    public var animationDuration : TimeInterval = 1.0
    
    /**
     hud animation view size.  Default is `(width: 60, height: 60)`
     */
    public var animationViewSize = CGSize(width: 60, height: 60)
}

public class CCHudManager {
    
    public static let shared = CCHudManager()
    
    public var style = CCHudStyle()
    
    public var activeCCHud : CCHud?
}
