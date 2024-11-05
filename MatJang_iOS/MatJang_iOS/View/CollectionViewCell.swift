//
//  CollectionViewCell.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 11/4/24.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell{
    static let identifier: String = "CollectionViewCell"
    
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 20)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //  Congifure Label
        contentView.addSubview(label)
        contentView.layer.cornerRadius = 6
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = UIColor.quaternaryLabel.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds    // label의 프레임을 cell의 바운드와 같게 조정
    }
    
    func configure(with viewModel: Matjip) {
        contentView.backgroundColor = .purple
        label.text = viewModel.place_name
    }
}
