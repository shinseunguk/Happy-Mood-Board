//
//  PhotoLibraryAuthorizationViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/29.
//

import UIKit

import SnapKit
import Then

import RxSwift
import RxCocoa

final class PhotoLibraryAuthorizationViewController: PartialViewController {
    
    enum Constants {
        static let titleLabelText = "사진 등록을 원하신다면,\n전체 사진에 대한 접근을 허용해주세요."
        static let descriptionLabelText = "*기기 설정 > Bee Happy > 사진에서 변경 가능해요."
        static let settingButtonTitle = "설정 변경하기"
    }
    
    private lazy var stackView: UIStackView = .init(arrangedSubviews: [
        titleLabel,
        imageView,
        descriptionLabel,
        settingButton
    ]
    ).then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 32
        $0.setCustomSpacing(16, after: imageView)
    }
    
    private let titleLabel: UILabel = .init().then {
        $0.text = Constants.titleLabelText
        $0.font = UIFont(name: "Pretendard-Bold", size: 18)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let imageView: UIImageView = .init().then {
        $0.image = UIImage(named: "library")
    }
    
    private let descriptionLabel: UILabel = .init().then {
        $0.text = Constants.descriptionLabelText
        $0.font = UIFont(name: "Pretendard-Regular", size: 14)
        $0.textColor = .gray400
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    private let settingButton: UIButton = .init(type: .system).then {
        $0.configurationUpdateHandler = { button in
            var container = AttributeContainer()
            container.font = UIFont(name: "Pretendard-Medium", size: 18)
            container.foregroundColor = button.isEnabled ? .gray900 : .gray400
            var configuration = UIButton.Configuration.filled()
            configuration.cornerStyle = .capsule
            configuration.background.backgroundColor = button.isEnabled ? .primary500 : .gray200
            configuration.attributedTitle = AttributedString(Constants.settingButtonTitle, attributes: container)
            button.configuration = configuration
        }
    }
    
    private let viewModel: PhotoLibraryAuthorizationViewModel = .init()
    private let disposeBag: DisposeBag = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCommonBackgroundColor()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
    
}

extension PhotoLibraryAuthorizationViewController: ViewAttributes {
    
    func setupSubviews() {
        view.addSubview(stackView)
    }
    
    func setupLayouts() {
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.snp.bottom).inset(26)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(223.88)
        }
        
        settingButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
    }
    
    func setupBindings() {
        let input = PhotoLibraryAuthorizationViewModel.Input(
            settingTrigger: settingButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        output.openSettingApp.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url) { _ in
                        owner.dismiss(animated: true)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
}
