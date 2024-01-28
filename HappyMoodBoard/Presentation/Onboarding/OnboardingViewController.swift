//
//  OnboardingViewController.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/28/24.
//

import Foundation

import UIKit

import RxSwift
import RxCocoa

final class OnboardingViewController: UIViewController, ViewAttributes {
    
    private let titleLabel = UILabel().then {
        $0.text = "행복을 담고"
        $0.textColor = .black
        $0.font = UIFont(name: "Pretendard-Bold", size: 24)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "여러분을 행복하게 만드는 아이템을 담아보세요."
        $0.textColor = .black
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
    }
    
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 0 // cell사이의 간격 설정
        $0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 390)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
        $0.isScrollEnabled = true
        $0.isPagingEnabled = true
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.register(OnboardingCollectionViewCell.self, forCellWithReuseIdentifier: "OnboardingCollectionViewCell")
    }
    
    private let pageControl = UIPageControl().then {
        $0.pageIndicatorTintColor = .gray200
        $0.currentPageIndicatorTintColor = .primary500
    }
    
    private let nextButton = UIButton(type: .system).then {
        $0.configurationUpdateHandler = { button in
            var container = AttributeContainer()
            container.font = UIFont(name: "Pretendard-Bold", size: 16)
            container.foregroundColor = button.isEnabled ? .gray900 : .gray400
            var configuration = UIButton.Configuration.filled()
            configuration.cornerStyle = .capsule
            configuration.background.backgroundColor = button.isEnabled ? .primary500 : .gray200
            configuration.attributedTitle = AttributedString("다음", attributes: container)
            button.configuration = configuration
        }
        $0.isHidden = true
    }
    
    let disposeBag: DisposeBag = .init()
    let viewModel = OnboardingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
}

extension OnboardingViewController {
    func setupSubviews() {
        [
            titleLabel,
            subTitleLabel,
            collectionView,
            pageControl,
            nextButton
        ].forEach { self.view.addSubview($0) }
    }
    
    func setupLayouts() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(collectionView.snp.top).multipliedBy(0.5)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(titleLabel)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.centerY.equalToSuperview()
            $0.height.equalTo(380)
        }
        
        pageControl.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(28)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-26)
            $0.height.equalTo(52)
        }
    }
    
    func setupBindings() {
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // MARK: - pageControll 처리를 위한 로직
        collectionView.rx.contentOffset
            .map { [weak self] offset in
                    guard let width = self?.collectionView.bounds.width, width != 0 else {
                        return 0
                    }
                    return Int(offset.x / width)
                }
            .bind(to: viewModel.index)
            .disposed(by: disposeBag)
        
        let input = OnboardingViewModel.Input(
            nextButtonEvent: nextButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        output.index
            .bind(to: pageControl.rx.currentPage)
            .disposed(by: disposeBag)
        
        output.item
            .do(onNext: { [weak self] element in
                self?.pageControl.numberOfPages = element.count
            })
            .bind(to: collectionView.rx.items(cellIdentifier: "OnboardingCollectionViewCell", cellType: OnboardingCollectionViewCell.self)) { (_, element, cell) in
                cell.bindData(image: element.2)
            }
            .disposed(by: disposeBag)
        
        output.indexItem
            .bind { [weak self] in
            self?.titleLabel.text = $0.0
            self?.subTitleLabel.text = $0.1
        }
        .disposed(by: disposeBag)
        
        output.isHiddenButton
            .map {
                !$0
            }
            .bind(to: nextButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.navigateToNext
            .bind { [weak self] in
                UserDefaults.standard.setValue(true, forKey: "firstOnboarding")
                
                let viewController = LoginViewController()
                self?.show(viewController, sender: nil)
            }
            .disposed(by: disposeBag)
    }
}

extension OnboardingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
}
