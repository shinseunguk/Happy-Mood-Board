//
//  PostDetailViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/18.
//

import UIKit

import Then
import SnapKit

import RxSwift
import RxCocoa

final class PostDetailViewController: UIViewController {
    
    private let backButton: UIBarButtonItem = .init(
        image: .init(named: "navigation.back"),
        style: .plain,
        target: nil,
        action: nil
    )
    
    private let registerButton: UIBarButtonItem = .init(
        image: .init(named: "navigation.edit"),
        style: .done,
        target: nil,
        action: nil
    )
    
    let textLabel: UILabel = .init().then {
        $0.textColor = .gray900
        $0.font = UIFont(name: "Pretendard-Bold", size: 24)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private let imageView: UIImageView = .init().then {
        $0.isHidden = true
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let viewModel: RegisterViewModel = .init()
    private let disposeBag: DisposeBag = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
}

extension PostDetailViewController: ViewAttributes {
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = registerButton
    }
    
    func setupSubviews() {
        [
            textLabel,
        ].forEach { view.addSubview($0) }
    }
    
    func setupLayouts() {
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupBindings() {
        backButton.rx.tap.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}
