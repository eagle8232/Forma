//
//  TaskInfoViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/3/26.
//

import UIKit

final class TaskInfoViewController: BaseViewController {
    
    private lazy var taskCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TaskInfoViewCell.self, forCellWithReuseIdentifier: TaskInfoViewCell.identifier)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    var tasks: [RoutineTask] = RoutineBlock.mockEvening.tasks // Mock data
   
    override func setupViews() {
        super.setupViews()
        view.backgroundColor = UIColor.backgroundPrimary.withAlphaComponent(0)
        layoutViews()
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
}

extension TaskInfoViewController {
    private func layoutViews() {
        view.addSubview(taskCollectionView)
        
        NSLayoutConstraint.activate([
            taskCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            taskCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            taskCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            taskCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension TaskInfoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskInfoViewCell.identifier, for: indexPath) as? TaskInfoViewCell else {
            return UICollectionViewCell()
        }
        cell.task = tasks[indexPath.row]
        return cell
    }
    
}

