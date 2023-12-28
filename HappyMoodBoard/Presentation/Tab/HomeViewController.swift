//
//  HomeViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/20.
//

import UIKit

import Then
import SnapKit

import RxSwift
import RxCocoa

final class HomeViewController: UIViewController {
    
    static let kHeaderLabelText = " 님,\n오늘의 행복 아이템을 남겨주세요."
    
    private let settingButton: UIBarButtonItem = .init(
        image: .init(named: "setting"),
        style: .plain,
        target: nil,
        action: nil
    )
   
    private let headerLabel: UILabel = .init().then {
        $0.text = " 님,\n오늘의 행복 아이템을 남겨주세요."
        $0.textColor = .gray900
        $0.font = UIFont(name: "Pretendard-Bold", size: 24)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private let mainImageView: UIImageView = .init(image: .init(named: "main"))
    
    private let viewModel: HomeViewModel = .init()
    private let disposeBag: DisposeBag = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }

}

extension HomeViewController: ViewAttributes {
    
    func setupNavigationBar() {
        let spacing = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacing.width = 12
        
        let titleLabel = UILabel().then {
            $0.textColor = .primary900
            $0.font = .init(name: "Pretendard-Bold", size: 16)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.17
            $0.attributedText = NSMutableAttributedString(
                string: "BEE HAPPY",
                attributes: [
                    NSAttributedString.Key.kern: -0.32,
                    NSAttributedString.Key.paragraphStyle: paragraphStyle
                ]
            )
        }
//        titleLabel.sizeToFit()
        
        navigationItem.leftBarButtonItems = [spacing, .init(customView: titleLabel)]
        navigationItem.rightBarButtonItems = [settingButton, spacing]
    }
    
    func setupSubviews() {
        [
            headerLabel,
            mainImageView
        ].forEach { view.addSubview($0) }
    }
    
    func setupLayouts() {
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        mainImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func setupBindings() {
        let input = HomeViewModel.Input(
            navigateToSetting: settingButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        output.username
            .bind { [weak self] username in
                let text = "\(username) \(self?.headerLabel.text ?? Self.kHeaderLabelText)"
                self?.headerLabel.text = text
                let attributedString = NSMutableAttributedString(string: text)
                attributedString.addAttribute(
                    .foregroundColor,
                    value: UIColor.primary900,
                    range: (text as NSString).range(of: username)
                )
                self?.headerLabel.attributedText = attributedString
            }
            .disposed(by: disposeBag)
        output.navigateToSetting
            .bind { [weak self] _ in
                let settingViewController = UIViewController()
                self?.show(settingViewController, sender: nil)
            }
            .disposed(by: disposeBag)
    }
    
}
