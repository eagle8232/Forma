//
//  TasksView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/4/26.
//

import UIKit

final class TasksView: UIView {
    
    private var taskCollectionView : UICollectionView!
    
    var tasks: [RoutineTask]
    
    init(tasks: [RoutineTask]) {
        self.tasks = tasks
        super.init(frame: .zero)
        configureCollectionView()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutViews() {
        taskCollectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(taskCollectionView)
    
        NSLayoutConstraint.activate([
            taskCollectionView.topAnchor.constraint(equalTo: topAnchor),
            taskCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            taskCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            taskCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

extension TasksView: UICollectionViewDelegate, UICollectionViewDataSource  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskInfoViewCell.identifier, for: indexPath) as? TaskInfoViewCell else {
            return UICollectionViewCell()
        }
        
        cell.task = tasks[indexPath.item]
        cell.taskState = tasks[indexPath.item].state
        return cell
    }
    
}

extension TasksView {
    private func configureCollectionView() {
        taskCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        taskCollectionView.translatesAutoresizingMaskIntoConstraints = false
        taskCollectionView.delegate = self
        taskCollectionView.dataSource = self
        taskCollectionView.register(TaskInfoViewCell.self, forCellWithReuseIdentifier: TaskInfoViewCell.identifier)
        taskCollectionView.backgroundColor = UIColor.clear
        taskCollectionView.showsVerticalScrollIndicator = false
    }
    // MARK: - Create Layout For Tasks Collection View
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(85))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
