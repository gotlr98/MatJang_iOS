//
//  SearchResultView.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 11/1/24.
//

import Foundation
import UIKit
import SnapKit


class SearchResultView: UIViewController{
    
    var search_list: [Matjip] = []
    let cellMultiplier: CGFloat = 0.5

    private lazy var btn = UIImageView().then{
        $0.image = UIImage(systemName: "magnifyingglass")
        $0.tintColor = .black
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(temp))
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
        
    }
    
    
    //  Create UICollectionView
    private let collectionView: UICollectionView = {
        //  Configure Layout
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        return collectionView
    }()
    
    override func viewDidLoad() {
        
        configureLayout()
        configureCollectionView()
        
        self.view.addSubview(btn)
        self.view.backgroundColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        btn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    func configureLayout() {
        // Add SubView
        view.addSubview(collectionView)
    
        collectionView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo((view.frame.size.height / 5 ) * 3)
            make.top.leading.equalTo(view.safeAreaLayoutGuide)
        }
    }
    

    
    func configureCollectionView() {
        // Attach CollectionView Delegate & DataSource
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Regist Cell
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
    }
    
    @objc func temp(){
        for li in search_list{
            print(li.place_name)
        }
    }
}

extension SearchResultView: UICollectionViewDelegate {
    
}

extension SearchResultView: UICollectionViewDataSource {
    
    /// Number of Section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /// Non-Optional
    /// NumberOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        search_list.count
    }
    
    /// Non-Optional
    /// CellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CollectionViewCell.identifier,
                for: indexPath
            ) as? CollectionViewCell else {
                fatalError()
            }
            
            cell.configure(with: search_list[indexPath.row])
            
            return cell
    }
}

extension SearchResultView: UICollectionViewDelegateFlowLayout {
    
    /// Cell Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = view.frame.size.width * cellMultiplier
        let height: CGFloat = view.frame.size.height * cellMultiplier
        
        let size: CGSize = CGSize(width: width, height: height)
        
        return size
    }
}
