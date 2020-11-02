//
//  CCToast.swift
//  CCToast
//
//  Created by chenh on 2020/10/20.
//

import UIKit

public class CCToast: UIView {
    
    public enum ToastPosition {
        case top
        case center
        case bottom
    }
    
    public enum ImagePosition {
        case top
        case left
    }

    public lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.numberOfLines = style.messageNumberOfLines
        messageLabel.font = style.messageFont
        messageLabel.textColor = style.messageColor
        messageLabel.lineBreakMode = .byTruncatingTail
        messageLabel.backgroundColor = UIColor.clear
        return messageLabel
    }()
    
    lazy var wrapperView: UIView = {
        let wrapperView = UIView()
        wrapperView.backgroundColor = style.backgroundColor
        wrapperView.layer.cornerRadius = style.cornerRadius
        wrapperView.clipsToBounds = true
        return wrapperView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var image : UIImage?
    
    var style: CCToastStyle = CCToastManager.shared.style
    
    var completion: ((Bool) -> Void)?
    
    public init(_ message: String,
                attributedMessage : NSAttributedString? = nil,
                image: UIImage? = nil,
                style: CCToastStyle = CCToastManager.shared.style,
                completion: ((_ didTap: Bool) -> Void)? = nil
    ) {
        super.init(frame: .zero)
        self.isUserInteractionEnabled = false
        self.style = style
        self.image = image
        self.completion = completion
        self.messageLabel.text = message
        if let attributedMessage = attributedMessage {
            self.messageLabel.attributedText = attributedMessage
        }
    
        self.addSubview(self.wrapperView)
        self.wrapperView.addSubview(self.messageLabel)
        
        if let image = self.image {
            self.imageView.image = image
            self.wrapperView.addSubview(self.imageView)
        }
    }
    
    public func becomeActive() {
        
        hideActiveToast()
        
        CCToastManager.shared.activeCCToast = self
        CCToastWindow.shared.isHidden = false
        
        self.perform(#selector(toastTimerDidFinish), with: nil, afterDelay: self.style.duration)
        
        self.alpha = 0.0
        UIView.animate(withDuration: CCToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.alpha = 1.0
        })
        
        if self.style.isTapDismiss {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleToastTapped))
            self.addGestureRecognizer(recognizer)
            self.isUserInteractionEnabled = true
            self.isExclusiveTouch = true
        }
    }
    
    // MARK: - Events
    
    @objc private func handleToastTapped() {
        hideToast(self, fromTap: true)
    }
    
    @objc private func toastTimerDidFinish() {
        hideToast(self, fromTap: false)
    }
    
    private func hideToast(_ toast: CCToast, fromTap: Bool) {
        CCToastManager.shared.activeCCToast = nil
        CCToastWindow.shared.isHidden = true
        NSObject.cancelPreviousPerformRequests(withTarget: toast, selector: #selector(toastTimerDidFinish), object: nil)
        UIView.animate(withDuration: toast.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState]) {
            toast.alpha = 0.0
        } completion: {_ in
            toast.removeFromSuperview()
            toast.completion?(fromTap)
        }
    }
    
    private func hideActiveToast() {
        if let toastView = CCToastManager.shared.activeCCToast {
            toastView.style.fadeDuration = 0.0
            self.hideToast(toastView, fromTap: false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let safeAreaInsets = UIApplication.shared.delegate?.window??.safeAreaInsets
        let safeTop = safeAreaInsets?.top ?? 0.0
        let safeRight = safeAreaInsets?.right ?? 0.0
        let safeBottom = safeAreaInsets?.bottom ?? 0.0
        let safeLeft = safeAreaInsets?.right ?? 0.0
        let topPadding: CGFloat = self.style.messageMaxEdge.top + safeTop
        let bottomPadding: CGFloat = self.style.messageMaxEdge.bottom + safeBottom
        
        var imageRect = CGRect.zero
        
        if self.image != nil {
            imageRect.origin.x = style.edge.left
            imageRect.origin.y = style.edge.top
            imageRect.size.width = style.imageSize.width
            imageRect.size.height = style.imageSize.height
        }

        let maxMessageSize = CGSize(
            width:
                UIScreen.main.bounds.width -
                style.messageMaxEdge.left -
                style.messageMaxEdge.right -
                safeRight - safeLeft -
                imageRect.size.width,
            height: UIScreen.main.bounds.height - style.messageMaxEdge.top -
                style.messageMaxEdge.bottom -
                safeBottom - safeTop
        )
        
        let messageSize = self.messageLabel.sizeThatFits(maxMessageSize)
        let actualWidth = min(messageSize.width, maxMessageSize.width)
        let actualHeight = min(messageSize.height, maxMessageSize.height)
        
        var messageRect = CGRect.zero
        messageRect.origin.x = imageRect.origin.x + imageRect.size.width + style.edge.left
        messageRect.origin.y = style.edge.top
        messageRect.size.width = actualWidth
        messageRect.size.height = actualHeight
        
        let longerWidth = messageRect.size.width
        let longerX = messageRect.origin.x
        var wrapperWidth = max((imageRect.size.width + style.edge.left + style.edge.right), (longerX + longerWidth + style.edge.right))
        var wrapperHeight = max((messageRect.origin.y + messageRect.size.height + style.edge.top), (imageRect.size.height + style.edge.top + style.edge.bottom))
        
        switch style.imagePosition {
        case .left:
            if longerWidth == 0  {
                wrapperWidth = wrapperWidth - style.edge.right
            }
            imageRect.origin.y = wrapperHeight/2 - imageRect.size.height/2
            messageRect.origin.y = wrapperHeight/2 - messageRect.size.height/2
            break
        case .top:
            messageRect.origin.x = style.edge.left
            messageRect.origin.y = imageRect.origin.y + imageRect.size.height + style.edge.top
            wrapperWidth = max((imageRect.size.width + (style.edge.left + style.edge.right)), (longerWidth + style.edge.left + style.edge.right ))
            wrapperHeight = imageRect.origin.y + imageRect.size.height + messageRect.size.height + style.edge.top + style.edge.bottom
            if longerWidth == 0  {
                wrapperHeight = wrapperHeight - style.edge.top
            }
            messageRect.origin.x = wrapperWidth/2 - messageRect.size.width/2
            imageRect.origin.x = wrapperWidth/2 - imageRect.size.width/2
        }
        
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        
        self.messageLabel.frame = messageRect
        if self.image != nil {
            self.imageView.frame = imageRect
        }
        
        self.frame = wrapperView.frame
        CCToastWindow.shared.frame = wrapperView.frame
        switch self.style.position {
        case .top:
            CCToastWindow.shared.center = CGPoint(x: UIScreen.main.bounds.size.width / 2.0, y: ((self.frame.size.height / 2.0) + topPadding + style.verticalOffset))
        case .center:
            CCToastWindow.shared.center = CGPoint(x: UIScreen.main.bounds.size.width / 2.0, y: (UIScreen.main.bounds.size.height / 2.0 + style.verticalOffset))
        case .bottom:
            CCToastWindow.shared.center = CGPoint(x: UIScreen.main.bounds.size.width / 2.0, y: (UIScreen.main.bounds.size.height - bottomPadding - self.frame.size.height / 2.0 + style.verticalOffset))
        }
    }
    
    @discardableResult
    public class func show(
        _ message: String,
        attributedMessage : NSAttributedString? = nil,
        image: UIImage? = nil,
        style: CCToastStyle = CCToastManager.shared.style,
        completion: ((_ didTap: Bool) -> Void)? = nil
    ) -> CCToast {
        let toastView = CCToast.init(
            message,
            attributedMessage: attributedMessage,
            image: image,
            style: style,
            completion: completion
        )
        toastView.becomeActive()
        CCToastWindow.shared.addSubview(toastView)
        return toastView
    }
}

public struct CCToastStyle {
    
    /**
     Toast backgroundColor. Default is `.black` at 80% opacity.
     */
    public var backgroundColor = UIColor.black.withAlphaComponent(0.8)
    
    /**
     Toast messageColor . Default is `.white`.
     */
    public var messageColor = UIColor.white
    
    /**
     The maximum toast distance from the screen margin.  Default is `(top: 30, left: 30, bottom: 30, right: 30)`.
     */
    public var messageMaxEdge = UIEdgeInsets.init(top: 30, left: 30, bottom: 30, right: 30)
    
    /**
     Toast messageFont . Default is `16.0`.
     */
    public var messageFont = UIFont.systemFont(ofSize: 16.0)
    
    /**
     Toast message linesNumber . Default is `0`.
     */
    public var messageNumberOfLines = 0
    
    /**
     Toast cornerRadius . Default is `5.0`.
     */
    public var cornerRadius: CGFloat = 5.0
    
    /**
     Toast image size . Default is `(width: 70, height: 70)`.
     */
    public var imageSize = CGSize.init(width: 70, height: 70)
    
    /**
     Toast  fade in/out animation duration. Default is 0.2.
     */
    public var fadeDuration: TimeInterval = 0.2
    
    /**
     Toast image position. Default is `.left`.
     */
    public var imagePosition = CCToast.ImagePosition.left
    
    /**
     Toast  position. Default is `.center`.
     */
    public var position = CCToast.ToastPosition.center
    
    /**
     Toast vertical Offset . Default is `0.0`.
     */
    public var verticalOffset: CGFloat = 0.0
    
    /**
     Toast padding. Default is `(top: 10, left: 10, bottom: 10, right: 10)`.
     */
    public var edge = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
    
    /**
     The default duration.
     */
    public var duration: TimeInterval = 3.0
    
    /**
     Enables or disables tap to dismiss on toast views. Default is `true`.
     */
    public var isTapDismiss = true
}


public class CCToastManager {
    
    /**
     The `CCToastManager` singleton instance.
     */
    public static let shared = CCToastManager()
    
    /**
     The shared style.
     */
    public var style = CCToastStyle()
    
    /**
     Toast currently displayed
     */
    public var activeCCToast : CCToast?
}

public class CCToastWindow : UIWindow {
    
    public static let shared = CCToastWindow(frame: .zero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.windowLevel = .init(rawValue: .greatestFiniteMagnitude)
        self.isHidden = false
        self.rootViewController = UIViewController()
        let willChangeStatusBarOrientationName = UIApplication.willChangeStatusBarOrientationNotification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.willChangeStatusBarOrientationName),
            name: willChangeStatusBarOrientationName,
            object: nil
        )
    }
    
    @objc private func willChangeStatusBarOrientationName() {
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
