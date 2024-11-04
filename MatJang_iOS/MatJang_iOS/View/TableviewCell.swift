//
//  TableviewCell.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 11/4/24.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    static let identifier = "TableViewCell"
        
    var colorView = UIView()
    var label = UILabel()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addContentView()
        
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addContentView() {
            
            // view.addSubview() 가 아닌
            // contentView !!!
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                              constant: 16),
            colorView.widthAnchor.constraint(equalToConstant: 80),
            colorView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 24)
        ])
        
    }
}
