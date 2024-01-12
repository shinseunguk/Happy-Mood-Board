//
//  SettingWebViewController.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/25/23.
//

import Foundation
import WebKit

import Then
import SnapKit

import RxSwift
import RxCocoa

final class SettingWebViewController: UIViewController, ViewAttributes, UIGestureRecognizerDelegate {
    
    var type: SettingType?
    
    private let webView = WKWebView()
    private let activityIndicator = UIActivityIndicatorView(style: .large).then {
        $0.color = .black
    }
    
    // 네비게이션
    private lazy var navigtaionTitle = NavigationTitle(title: type?.title ?? "")
    private let navigationItemBack = NavigtaionItemBack()
    //
    
    private let disposeBag: DisposeBag = .init()
    
    init(type: SettingType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setWebView()
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
}

extension SettingWebViewController: WKNavigationDelegate {
    func setWebView() {
        if let url = URL(string: type?.URL ?? "") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func setupNavigationBar() {
        self.navigationItem.titleView = navigtaionTitle
        self.navigationItem.leftBarButtonItem = navigationItemBack
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func setupSubviews() {
        self.view.addSubview(webView)
        webView.addSubview(activityIndicator)
    }
    
    func setupLayouts() {
        webView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    func setupBindings() {
        navigationItemBack.rxTap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        webView.rx.didStartLoad
            .subscribe(onNext: { [weak self] _ in
                self?.activityIndicator.startAnimating()
            })
            .disposed(by: disposeBag)
        
        webView.rx.didFinishLoad
            .subscribe(onNext: { [weak self] _ in
                self?.activityIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)
    }
}
