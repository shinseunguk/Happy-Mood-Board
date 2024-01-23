//
//  FullImageViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/23.
//

import UIKit

import Then
import SnapKit

import RxSwift
import RxCocoa

final class FullImageViewController: UIViewController {
    
    private let imageView: AutoSizeImageView = .init(maxSize: UIScreen.main.bounds.width).then {
        $0.backgroundColor = .primary500
        $0.layer.borderColor = UIColor.primary500?.cgColor
        $0.layer.borderWidth = 4
        $0.contentMode = .scaleAspectFit
    }
    
    private let minimizeButton: UIButton = .init(type: .system).then {
        $0.setImage(.init(named: "minimize"), for: .init())
    }
    
    private let image: UIImage
    private let disposeBag: DisposeBag = .init()
    
    init(image: UIImage?) {
        self.image = image ?? .init()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCommonBackgroundColor()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut) { [weak self] in
            self?.view.transform = .identity
            self?.view.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) { [weak self] in
            self?.view.transform = .identity
            self?.view.isHidden = true
        }
    }
    
}

extension FullImageViewController: ViewAttributes {
    
    func setupSubviews() {
        [
            imageView,
            minimizeButton
        ].forEach { view.addSubview($0) }
    }
    
    func setupLayouts() {
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
            make.height.lessThanOrEqualToSuperview()
        }
        
        minimizeButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(imageView).inset(8)
        }
    }
    
    func setupBindings() {
        // 이미지뷰 사이즈
        imageView.image = image
        let newSize = imageView.getSize()
        imageView.snp.remakeConstraints { make in
            make.width.equalTo(newSize.width)
            make.height.equalTo(newSize.height)
            make.center.equalToSuperview()
        }
        
        minimizeButton.rx.tap.asDriver()
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}
