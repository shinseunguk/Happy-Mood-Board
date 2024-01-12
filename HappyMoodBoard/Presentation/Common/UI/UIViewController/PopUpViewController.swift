//
//  PopUpViewController.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/11/24.
//

import Foundation
import UIKit

import SnapKit
import Then


class PopUpViewController: UIViewController {
    private var titleText: String?
    private var messageText: String?
    private var attributedMessageText: NSAttributedString?
    private var contentView: UIView?
    
    private lazy var containerView: UIView = UIView().then {
        $0.backgroundColor = .primary100
        $0.layer.cornerRadius = 10
        $0.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }
    
    private lazy var containerStackView: UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12.0
        $0.alignment = .center
    }
    
    private lazy var buttonStackView: UIStackView = UIStackView().then {
        $0.spacing = 14.0
        $0.distribution = .fillEqually
    }
    
    private lazy var titleLabel: UILabel? = UILabel().then {
        $0.text = titleText
        $0.textAlignment = .center
        $0.font = UIFont(name: "Pretendard-Bold", size: 18)
        $0.numberOfLines = 0
        $0.textColor = .black
    }
    
    private lazy var messageLabel: UILabel? = {
        let label = UILabel().then {
            $0.textAlignment = .center
            $0.font = UIFont(name: "Pretendard-Regular", size: 16)
            $0.textColor = .black
            $0.numberOfLines = 0
        }
        
        if let messageText = messageText {
            label.text = messageText
        }
        
        if let attributedMessageText = attributedMessageText {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            
            let attributedString = NSMutableAttributedString(string: attributedMessageText.string)
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
            
            label.attributedText = attributedString
        }
        
        return label
    }()
    
    
    convenience init(titleText: String? = nil,
                     messageText: String? = nil,
                     attributedMessageText: NSAttributedString? = nil) {
        self.init()
        
        self.titleText = titleText
        self.messageText = messageText
        self.attributedMessageText = attributedMessageText
        /// present 시 fullScreen (화면을 덮도록 설정) -> 설정 안하면 pageSheet 형태 (위가 좀 남아서 밑에 깔린 뷰가 보이는 형태)
        modalPresentationStyle = .overFullScreen
    }
    
    convenience init(contentView: UIView) {
        self.init()
        
        self.contentView = contentView
        modalPresentationStyle = .overFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        addSubviews()
        makeConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // curveEaseOut: 시작은 천천히, 끝날 땐 빠르게
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // curveEaseIn: 시작은 빠르게, 끝날 땐 천천히
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = true
        }
    }
    
    public func addActionToButton(title: String? = nil,
                                  titleColor: UIColor = .white,
                                  backgroundColor: UIColor = .blue,
                                  completion: (() -> Void)? = nil) {
        guard let title = title else { return }
        
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .bold)
        
        // enable
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.setBackgroundImage(backgroundColor.image(), for: .normal)
        
        // disable
        button.setTitleColor(.gray, for: .disabled)
        button.setBackgroundImage(UIColor.gray.image(), for: .disabled)
        
        // layer
        button.layer.cornerRadius = 20.0
        button.layer.masksToBounds = true
        
        button.addAction(for: .touchUpInside) { _ in
            completion?()
        }
        
        buttonStackView.addArrangedSubview(button)
    }
    
    private func setupViews() {
        view.addSubview(containerView)
        containerView.addSubview(containerStackView)
        view.backgroundColor = .black.withAlphaComponent(0.2)
    }
    
    private func addSubviews() {
        view.addSubview(containerStackView)
        
        if let contentView = contentView {
            containerStackView.addSubview(contentView)
        } else {
            if let titleLabel = titleLabel {
                containerStackView.addArrangedSubview(titleLabel)
            }
            
            if let messageLabel = messageLabel {
                containerStackView.addArrangedSubview(messageLabel)
            }
        }
        
        if let lastView = containerStackView.subviews.last {
            containerStackView.setCustomSpacing(24.0, after: lastView)
        }
        
        containerStackView.addArrangedSubview(buttonStackView)
    }
    
    private func makeConstraints() {
        containerView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(45)
            $0.top.greaterThanOrEqualToSuperview().offset(32)
            $0.bottom.lessThanOrEqualToSuperview().offset(-32)
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.top).offset(24)
            $0.leading.equalTo(containerView.snp.leading).offset(24)
            $0.bottom.equalTo(containerView.snp.bottom).offset(-24)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-24)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.width.equalTo(containerStackView.snp.width)
        }
    }
}

// MARK: - Extension

extension UIColor {
    /// Convert color to image
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

extension UIControl {
    public typealias UIControlTargetClosure = (UIControl) -> ()
    
    private class UIControlClosureWrapper: NSObject {
        let closure: UIControlTargetClosure
        init(_ closure: @escaping UIControlTargetClosure) {
            self.closure = closure
        }
    }
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: UIControlTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? UIControlClosureWrapper else { return nil }
            return closureWrapper.closure
            
        } set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, UIControlClosureWrapper(newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
    
    public func addAction(for event: UIControl.Event, closure: @escaping UIControlTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIControl.closureAction), for: event)
    }
    
}
