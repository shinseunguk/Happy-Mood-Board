//
//  MyTabViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/20.
//

import UIKit

import Then
import SnapKit

import RxSwift
import RxCocoa

final class MyTabViewController: UIViewController {
    
    private let settingButton: UIBarButtonItem = .init(
        image: .init(named: "setting"),
        style: .plain,
        target: nil,
        action: nil
    )
    
    private lazy var scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
    }
    
    private let contentView = UIView()
    
    static let kHeaderLabelText = "님의 꿀단지에는\n어떤 행복이 담겨있나요?"
    
    private let headerLabel: UILabel = .init().then {
        $0.textColor = .gray900
        $0.font = UIFont(name: "Pretendard-Bold", size: 24)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private let tagScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false // 수평 스크롤 인디케이터 표시 여부
        $0.isDirectionalLockEnabled = true // 수평 스크롤 고정 여부 (수직 스크롤을 막고 수평 스크롤만 허용)
        $0.alwaysBounceHorizontal = true // 스크롤이 컨텐츠의 크기보다 작아도 가로로 스크롤 가능하도록 설정
        $0.isPagingEnabled = false // 페이지별 스크롤 여부 (필요에 따라 설정)
        $0.isScrollEnabled = true
        $0.isHidden = true
    }
    
    private let tagStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    private let stickyScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false // 수평 스크롤 인디케이터 표시 여부
        $0.isDirectionalLockEnabled = true // 수평 스크롤 고정 여부 (수직 스크롤을 막고 수평 스크롤만 허용)
        $0.alwaysBounceHorizontal = true // 스크롤이 컨텐츠의 크기보다 작아도 가로로 스크롤 가능하도록 설정
        $0.isPagingEnabled = false // 페이지별 스크롤 여부 (필요에 따라 설정)
        $0.isScrollEnabled = true
        $0.backgroundColor = .primary100
        $0.isHidden = true
    }
    
    private let stickyHeaderTagStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    private lazy var tableView = CustomTableView().then {
        $0.isScrollEnabled = false
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = .primary100
        $0.register(MyTabTableViewCell.self, forCellReuseIdentifier: "MyTabTableViewCell")
        // 셀의 높이 자동 조절
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 100.0 // 셀의 기본 예상 높이
        $0.separatorStyle = .none
    }
    
    private let emptyImageView = UIImageView().then {
        $0.isHidden = true
        $0.image = UIImage(named: "happyItem.empty")
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    let disposeBag : DisposeBag = .init()
    let viewModel: MyTabViewModel = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }

}

extension MyTabViewController: ViewAttributes {
    
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
        navigationItem.rightBarButtonItems = [settingButton, .fixedSpace(12)]
    }
    
    func setupSubviews() {
        [
            scrollView,
            stickyScrollView,
            emptyImageView
        ].forEach { self.view.addSubview($0) }
        
        [
            contentView
        ].forEach { self.scrollView.addSubview($0) }
        
        [
            headerLabel,
            tagScrollView,
            tableView
        ].forEach { self.contentView.addSubview($0) }
        
        [
            stickyHeaderTagStackView
        ].forEach { self.stickyScrollView.addSubview($0) }
        
        [
            tagStackView
        ].forEach { self.tagScrollView.addSubview($0) }
    }
    
    func setupLayouts() {
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        
        stickyScrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(46)
        }
        
        emptyImageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(30)
            $0.height.equalTo(emptyImageView.snp.width).multipliedBy(0.48)
        }
        
        stickyHeaderTagStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
            $0.width.equalTo(view.snp.width)
        }
        
        headerLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        tagScrollView.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(46)
        }
        
        tagStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(tagScrollView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
        }
    }
    
    func setupBindings() {
        // 테이블 뷰 델리게이트 및 데이터 소스 설정
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        
        let input = MyTabViewModel.Input (
            viewWillAppear: rx.viewWillAppear.asObservable(),
            navigationRight: settingButton.rx.tap.asObservable(),
            scrollViewDidScroll: scrollView.rx.didScroll.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.username.asDriver(onErrorJustReturn: "")
            .debug("사용자명")
            .drive(with: self) { owner, username in
                let text = "\(username) \(Self.kHeaderLabelText)"
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
        
        output.navigationRight.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                let settingViewController = SettingIndexViewController()
                settingViewController.hidesBottomBarWhenPushed = true // Tabbar 숨기기
                owner.show(settingViewController, sender: nil)
            }
            .disposed(by: disposeBag)
        
        output.scrollViewDidScroll
            .skip(2) // TODO: 이 line을 없애면 처음에 stickyView가 노출, 일단 하드코딩..
            .bind { [weak self] in
                // 5. 핵심 - frame.minY를 통해 sticky 타이밍을 계산
                //            traceLog(self?.scrollView.contentOffset.y)
                //            traceLog(self?.tagView.frame.minY)
                let shouldShowSticky = (self?.scrollView.contentOffset.y)! >= (self?.tagScrollView.frame.minY)!
                self?.stickyScrollView.isHidden = !shouldShowSticky
            }
            .disposed(by: disposeBag)
        
        // MARK: - TAG set, stickyView와 tagView
        output.tag.subscribe(onNext: { [weak self] tag in
            
            // MARK: - StickyView
            for (index, element) in tag.enumerated() {
                let tagButton = TagButton(tagId: element.0, title: element.1, bgColor: .primary600/*element.1*/)
                self?.stickyHeaderTagStackView.addArrangedSubview(tagButton)
                
                tagButton.rx.tap
                    .compactMap {
                        (index, tagButton.tagId ?? 0)
                    }
                    .bind(to: self!.viewModel.selectedIndex)
                .disposed(by: self!.disposeBag)
                
                self?.viewModel.selectedIndex.bind {
                    if index == $0.0 {
                        tagButton.backgroundColor = .accent300
                        tagButton.layer.borderColor = UIColor.accent300?.cgColor
                    } else {
                        tagButton.backgroundColor = .white
                        tagButton.layer.borderColor = UIColor.primary600?.cgColor
                    }
                }
                .disposed(by: self!.disposeBag)
                
                tagButton.snp.makeConstraints {
                    $0.height.equalTo(30)
                    
                    if index == 0 {
                        $0.leading.equalTo((self?.stickyHeaderTagStackView.snp.leading)!).offset(24)
                    }
                }
            }
            
            // MARK: - TagView
            for (index, element) in tag.enumerated() {
                let tagButton = TagButton(tagId: element.0, title: element.1, bgColor: .primary600/*element.1*/)
                self?.tagStackView.addArrangedSubview(tagButton)
                
                tagButton.rx.tap
                    .compactMap {
                        (index, tagButton.tagId ?? 0)
                    }
                    .bind(to: self!.viewModel.selectedIndex)
                .disposed(by: self!.disposeBag)
                
                self?.viewModel.selectedIndex.bind {
                    if index == $0.0 {
                        tagButton.backgroundColor = .accent300
                        tagButton.layer.borderColor = UIColor.accent300?.cgColor
                    } else {
                        tagButton.backgroundColor = .white
                        tagButton.layer.borderColor = UIColor.primary600?.cgColor
                    }
                }
                .disposed(by: self!.disposeBag)
                
                tagButton.snp.makeConstraints {
                    $0.height.equalTo(30)
                    
                    if index == 0 {
                        $0.leading.equalTo((self?.tagStackView.snp.leading)!).offset(24)
                    }
                }
            }
        })
        .disposed(by: disposeBag)
        
        output.happyItem
            .map {
                $0.count == 0
            }
            .bind { [weak self] in
                    self?.emptyImageView.isHidden = !$0
                    self?.tagScrollView.isHidden = $0
            }
            .disposed(by: disposeBag)
        
        output.happyItem
            .bind(to: tableView.rx.items(cellIdentifier: "MyTabTableViewCell", cellType: MyTabTableViewCell.self)) { (row, element, cell) in
                cell.bindData(post: element)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .withLatestFrom(output.happyItem) { indexPath, happyItem in
                return (indexPath, happyItem)
            }
            .map { (indexPath, happyItem) in
                return (indexPath, happyItem[indexPath.row].id)
            }
            .subscribe { [weak self] (indexPath, postId) in
                traceLog(postId)
                let viewController = PostDetailViewController(viewModel: .init(postId: postId))
                self?.show(viewController, sender: nil)
            }
            .disposed(by: disposeBag)
    }
}

extension MyTabViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
