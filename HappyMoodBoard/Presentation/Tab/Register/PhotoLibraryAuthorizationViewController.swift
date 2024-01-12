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

final class PhotoLibraryAuthorizationViewController: UIViewController {
    
    private let titleLabel: UILabel = .init().then {
        $0.text = "사진 등록을 원하신다면,\n전체 사진에 대한 접근을 허용해주세요."
        $0.font = UIFont(name: "Pretendard-Bold", size: 18)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let imageView: UIImageView = .init().then {
        $0.image = UIImage(named: "library")
    }
    
    private let descriptionLabel: UILabel = .init().then {
        $0.text = "*기기 설정 > Bee Happy > 사진에서 변경 가능해요."
        $0.font = UIFont(name: "Pretendard-Bold", size: 12)
        $0.textColor = .gray600
    }
    
    private let settingButton: UIButton = .init(type: .system).then {
        $0.setTitle("설정 변경하기", for: .normal)
        $0.setTitleColor(.gray900, for: .normal)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14)
        // TODO: 밑줄
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
        [
            titleLabel,
            imageView,
            descriptionLabel,
            settingButton
        ].forEach { view.addSubview($0) }
    }
    
    func setupLayouts() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40.5)
            make.leading.trailing.equalToSuperview().inset(60)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
            make.width.equalTo(322)
            make.height.equalTo(172)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(25)
            make.leading.equalTo(imageView.snp.leading).offset(8)
            make.trailing.equalToSuperview()
        }
        
        settingButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-22)
        }
    }
    
    func setupBindings() {
        let input = PhotoLibraryAuthorizationViewModel.Input(
            settingTrigger: settingButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        output.openSettingApp
            .subscribe(onNext: {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url) { [weak self] _ in
                        self?.dismiss(animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
}