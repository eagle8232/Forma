//
//  HomeViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/19/26.
//

import UIKit
import FirebaseAuth

final class HomeViewController: BaseViewController {
    
    private var viewModel: HomeViewModel!
    
    private lazy var timelineScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private lazy var timelineContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var dateTextView: FormaTextView = {
        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.addCaption(viewModel?.getDate() ?? "", typography: .monospacedSmall)
        tv.setAlignment(.leading)
        return tv
    }()
    
    private lazy var verticalTimelineView: VerticalTimelineView = {
        let view = VerticalTimelineView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private var headerView: HomeHeaderView!
    
    private lazy var routineInfoViewCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RoutineInfoViewCell.self, forCellWithReuseIdentifier: RoutineInfoViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    
    
    init(viewModel: HomeViewModel!) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func setupViews() {
        super.setupViews()
        applyGradientBackground()
        setupLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerView = HomeHeaderView(frame: CGRect(x: view.safeAreaInsets.left, y: 0, width: 200, height: 100))
        
        let barButtonItem = UIBarButtonItem(customView: headerView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToRoutine()
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Private Methods
    private func scrollToRoutine() {
        guard let selectedRoutine = viewModel.selectedRoutine,
              let index = viewModel.routines.firstIndex(where: { $0.id == selectedRoutine.id }) else {
            return
        }
        let indexPath = IndexPath(item: index, section: 0)
        routineInfoViewCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
    }
}

extension HomeViewController: VerticalTimelineViewDelegate {
    func didSelectRoutine(view: VerticalTimelineView, _ routine: RoutineBlock) {
        
    }
}

extension HomeViewController: RoutineInfoViewDelegate {
    func nextTask(_ view: RoutineInfoView) {
        
    }
}

// MARK: - Layout
extension HomeViewController {
    private func setupLayouts() {
        
        view.addSubview(routineInfoViewCollectionView)
        
        NSLayoutConstraint.activate([
            routineInfoViewCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            routineInfoViewCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            routineInfoViewCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            routineInfoViewCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.routines.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoutineInfoViewCell.identifier, for: indexPath) as? RoutineInfoViewCell else {
            return UICollectionViewCell()
        }
        for routine in viewModel.routines {
            
        }
        cell.currentTask = viewModel.routines[indexPath.item].tasks[indexPath.item]
        cell.tasks = viewModel.routines[indexPath.item].tasks
        return cell
    }
}
