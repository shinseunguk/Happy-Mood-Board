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

enum TagListItem {
    case tag(Tag)
    case add
    
    var id: Int {
        switch self {
        case .add: return -1
        case .tag(let tag): return tag.id
        }
    }
}

struct TagListSection {
    var header: String = ""
    var items: [Item]
}

extension TagListSection: SectionModelType {
    typealias Item = TagListItem
    
    var identity: String { header }
    
    init(original: TagListSection, items: [Item]) {
        self = original
        self.items = items
    }
}

final class TagListViewController: UIViewController {
    
    enum Constants {
        static let cellHeight: CGFloat = 30
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
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(.gray900, for: .normal)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        // TODO: 밑줄
    }
    
    private let disposeBag: DisposeBag = .init()
    private let viewModel: TagListViewModel = .init()
    
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
        navigationItem.title = "태그 선택"
        navigationItem.rightBarButtonItems = [editButton, .fixedSpace(20)]
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    func setupSubviews() {
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
        
        output.navigateToAdd.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.navigateToAdd()
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
            print(tag)
        }
    }
    
    func navigateToAdd() {
        let viewController = AddTagViewController()
        show(viewController, sender: nil)
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
