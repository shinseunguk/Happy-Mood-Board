//
//  HomeViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/20.
//

import UIKit

import Then
import SnapKit
import Lottie

import RxSwift
import RxCocoa
import RxViewController

final class HomeViewController: UIViewController {
    
    enum Constants {
        static let headerLabelText = "님,\n행복 아이템을 꿀단지에 담아보세요."
    }
    
    private let headerLabel = HeaderLabel(labelText: Constants.headerLabelText).then {
        $0.textColor = .gray900
        $0.font = UIFont(name: "Pretendard-Bold", size: 24)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private let animationView: LottieAnimationView = .init(name: "beehome").then {
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .loop
        $0.play()
    }
    
    private let viewModel: HomeViewModel = .init()
    private let disposeBag: DisposeBag = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        traceLog("accessToken =>\n\(UserDefaults.standard.string(forKey: "accessToken") ?? "")")
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }

}

extension HomeViewController: ViewAttributes {
    
    func setupNavigationBar() {
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
        navigationItem.leftBarButtonItems = [.fixedSpace(12), .init(customView: titleLabel)]
    }
    
    func setupSubviews() {
        [
            headerLabel,
            animationView
        ].forEach { view.addSubview($0) }
    }
    
    func setupLayouts() {
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
            make.leading.trailing.equalToSuperview().offset(24)
        }
        
        animationView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview().offset(10)
            $0.width.height.equalTo(1080)
        }
    }
    
    func setupBindings() {
        let input = HomeViewModel.Input(
            viewWillAppear: rx.viewWillAppear.asObservable(),
            viewWillDisAppear: rx.viewWillDisappear.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.username.asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, username in
                guard let username = username else { return }
                let text = "\(username) \(Self.Constants.headerLabelText)"
                owner.headerLabel.text = text
                let attributedString = NSMutableAttributedString(string: text)
                attributedString.addAttribute(
                    .foregroundColor,
                    value: UIColor.primary900,
                    range: (text as NSString).range(of: username)
                )
                owner.headerLabel.attributedText = attributedString
            }
            .disposed(by: disposeBag)
        
        output.error.asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, error in
                owner.headerLabel.text = error
            }
            .disposed(by: disposeBag)
    }
    
}
