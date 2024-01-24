//
//  MyTabTableViewCell.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/21/24.
//

import UIKit
import SnapKit
import Then

class MyTabTableViewCell: UITableViewCell {
    // 셀 내부의 요소들을 정의합니다.
    
    let myTabView = UIView().then {
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.primary600?.cgColor
        $0.layer.cornerRadius = 15
        $0.isUserInteractionEnabled = true
    }
    
    let createdAtLabel = UILabel().then {
//        $0.layer.borderWidth = 1
        $0.textColor = .primary900
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
    }
    
    let titleLabel = UILabel().then {
//        $0.layer.borderWidth = 1
        $0.textColor = .black
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
        $0.numberOfLines = 0
    }
    
    let postImageView = UIImageView().then {
        $0.image = UIImage(named: "test.image")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        setupSelf()
        setupSubviews()
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = .primary100
    }
    
    func setupSubviews() {
        
        [
            myTabView
        ].forEach { contentView.addSubview($0) }
        
        [
            createdAtLabel,
            titleLabel
        ].forEach { myTabView.addSubview($0) }
    }
    
    func setupLayouts() {
        myTabView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0))
        }
        
        createdAtLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(createdAtLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(createdAtLabel)
            $0.bottom.equalTo(-24)
        }
    }
    
    func setupImageView() {
        myTabView.addSubview(postImageView)
        
        titleLabel.snp.removeConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(createdAtLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(createdAtLabel)
        }
        
        postImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(postImageView.snp.width)
            $0.bottom.equalTo(-24)
        }
    }
    
    /// Cell Bind 함수
    /// - Parameter tuple: (게시글 ID ,생성일자, 게시글 내용, 이미지 path)
    func bindData(post: Post) {
        self.createdAtLabel.text = convertDateString(post.createdAt) ?? "9999/99/99"
        self.titleLabel.text = post.comments
        
        // TODO: 이미지 SET 조건절로 이미지 addsubview 할건지 말건지
        false ? setupImageView() : nil
    }
}
