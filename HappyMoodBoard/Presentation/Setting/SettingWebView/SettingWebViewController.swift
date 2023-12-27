//
//  SettingWebViewController.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/25/23.
//

import Foundation

import Then
import SnapKit

import RxSwift
import RxCocoa

final class SettingWebViewController: UIViewController, ViewAttributes, UIGestureRecognizerDelegate {
    
    var navTitle: String?
    
    // 네비게이션
    private lazy var navigtaionTitle = NavigationTitle(title: navTitle ?? "")
    private let navigationItemBack = NavigtaionItemBack()
    //
    
    private let disposeBag: DisposeBag = .init()
    
    init(type: SettingType) {
        super.init(nibName: nil, bundle: nil)
        self.navTitle = type.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
}

extension SettingWebViewController {
    func setupNavigationBar() {
        guard let navTitle = navTitle else {
            self.navigationItem.titleView = NavigationTitle(title: "")
            return
        }
        
        self.navigationItem.titleView = NavigationTitle(title: navTitle)
        self.navigationItem.leftBarButtonItem = navigationItemBack
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func setupSubviews() {
        
    }
    
    func setupLayouts() {
        
    }
    
    func setupBindings() {
        navigationItemBack.rxTap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
