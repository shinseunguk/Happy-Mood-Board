//
//  AlertViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/22.
//

import UIKit

import Then
import SnapKit

final class PostDetailModalViewController: UIViewController {

    private let buttonStackView: UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 16.0
    }
    
    private let closeButton: UIButton = .init(type: .system).then {
        let text = "닫기"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes([
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont(name: "Pretendard-Medium", size: 16),
            .foregroundColor: UIColor.gray900
        ], range: NSRange(location: 0, length: text.count))
        $0.setAttributedTitle(attributedString, for: .init())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        setCommonBackgroundColor()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
    
    @objc
    private func closeButtonTapped() {
        dismiss(animated: true)
    }
        
    func addAction(
        title: String = "",
        completion: (() -> Void)? = nil
    ) {
        let button = UIButton().then {
            $0.configurationUpdateHandler = { button in
                var container = AttributeContainer()
                container.font = UIFont(name: "Pretendard-Medium", size: 18)
                container.foregroundColor = .gray900
                var configuration = UIButton.Configuration.filled()
                configuration.cornerStyle = .capsule
                configuration.background.backgroundColor = button.isEnabled ? .primary500 : .gray200
                configuration.attributedTitle = AttributedString(title, attributes: container)
                button.configuration = configuration
            }
        }
        button.addAction(for: .touchUpInside) { _ in
            completion?()
        }
        buttonStackView.addArrangedSubview(button)
        button.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
    }
}

extension PostDetailModalViewController: ViewAttributes {
    
    func setupSubviews() {
        [
            buttonStackView,
            closeButton
        ].forEach { view.addSubview($0) }
        
    }
    
    func setupLayouts() {
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(34)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(8)
        }
    }
    
    func setupBindings() {
        
    }
    
}
