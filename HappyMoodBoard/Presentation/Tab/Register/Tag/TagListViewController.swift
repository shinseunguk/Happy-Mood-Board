//
//  TagListViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import UIKit

import Then
import SnapKit

import RxSwift
import RxCocoa
import RxDataSources

final class TagListViewController: UIViewController {
    
    enum Constants {
        static let cellHeight: CGFloat = 30
        static let lineHeight: CGFloat = 24
    }
    
    private let titleLabel: UILabel = .init().then {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.17
        $0.attributedText = NSMutableAttributedString(
            string: "태그 선택",
            attributes: [
                NSAttributedString.Key.kern: -0.36,
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                .font: UIFont(name: "Pretendard-Bold", size: 18),
                .foregroundColor: UIColor.gray900
            ]
        )
    }
    
    private let editButton: UIBarButtonItem = .init(title: "편집", style: .plain, target: nil, action: nil).then {
        $0.tintColor = .gray500
        $0.setTitleTextAttributes(
            [.font: UIFont(name: "Pretendard-Medium", size: 16)]
            , for: .init()
        )
    }
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 0
    }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.itemSize = .init(width: Constants.cellHeight, height: Constants.cellHeight)
        layout.minimumInteritemSpacing = 8
        let verticalInset: CGFloat = 32
        let horizontalInset: CGFloat = 24
        layout.sectionInset = .init(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.allowsSelection = true
        collectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = .primary100
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let closeButton: UIButton = .init(type: .system).then {
        let text = "닫기"
        let attributedString = NSMutableAttributedString(string: text)
        var paragraphStyle = NSMutableParagraphStyle()
        let font = UIFont(name: "Pretendard-Medium", size: 16)
        paragraphStyle.maximumLineHeight = Constants.lineHeight
        paragraphStyle.minimumLineHeight = Constants.lineHeight
        attributedString.addAttributes([
            .baselineOffset: (Constants.lineHeight - (font?.lineHeight ?? .zero)) / 2,
            .paragraphStyle: paragraphStyle,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: font,
            .foregroundColor: UIColor.gray900
        ], range: NSRange(location: 0, length: text.count))
        $0.setAttributedTitle(attributedString, for: .init())
    }
    
    private let disposeBag: DisposeBag = .init()
    private let viewModel: TagListViewModel
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<TagListSection> = .init(
        configureCell: {
        dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TagCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? TagCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: item)
            return cell
        }
    )
    
    init(viewModel: TagListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
    
}

extension TagListViewController: ViewAttributes {
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItems = [.fixedSpace(20), .init(customView: titleLabel)]
        navigationItem.rightBarButtonItem = editButton
        navigationItem.backButtonDisplayMode = .minimal
        
        // shadow
        navigationController?.navigationBar.backgroundColor = .primary100
        navigationController?.navigationBar.layer.masksToBounds = false
        navigationController?.navigationBar.layer.shadowColor = UIColor.gray200?.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 1
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        navigationController?.navigationBar.layer.shadowRadius = 1
    }
    
    func setupSubviews() {
        view.setCornerRadiusForTopCorners(radius: 30)
        view.addSubview(contentStackView)
        
        [
            collectionView,
            closeButton
        ].forEach { contentStackView.addArrangedSubview($0) }
    }
    
    func setupLayouts() {
        contentStackView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        closeButton.snp.makeConstraints { make in
            make.height.equalTo(41)
        }
    }
    
    func setupBindings() {
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        let input = TagListViewModel.Input(
            viewWillAppear: rx.viewWillAppear.asObservable(),
            editButtonTapped: editButton.rx.tap.asObservable(),
            itemSelected: collectionView.rx.modelSelected(TagListItem.self).asObservable(),
            closeButtonTapped: closeButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        output.navigateToEdit.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                let viewController = EditTagViewController()
                owner.show(viewController, sender: nil)
            }
            .disposed(by: disposeBag)
        
        output.items
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.navigateToAdd.asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, hasExistingTag in
                owner.navigateToAdd(hasExistingTag: hasExistingTag)
            }
            .disposed(by: disposeBag)
        
        output.dismiss.asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, tag in
                owner.navigatToBack(tag)
            }
            .disposed(by: disposeBag)
    }
    
    func navigatToBack(_ tag: Tag?) {
        dismiss(animated: true) { [weak self] in
            self?.viewModel.tagSelected.onNext(tag)
        }
    }
    
    func navigateToAdd(hasExistingTag: Bool) {
        let viewController = AddTagViewController(viewModel: .init(hasExistingTag: hasExistingTag))
        if hasExistingTag {
            show(viewController, sender: nil)
        } else {
            viewController.navigationItem.hidesBackButton = true
            navigationController?.popViewController(animated: false)
            navigationController?.pushViewController(viewController, animated: false)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TagListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataSource[indexPath.section].items[indexPath.row]
        switch item {
        case .add:
            return .init(width: Constants.cellHeight, height: Constants.cellHeight)
        case .tag(let tag):
            let dummyCell = TagCollectionViewCell()
            dummyCell.configure(with: .tag(tag))
            dummyCell.nameButton.sizeToFit()
            var size = dummyCell.frame.size
            size.height = Constants.cellHeight
            return size
        }
    }
    
}

