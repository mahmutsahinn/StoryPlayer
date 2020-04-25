//
//  StoryViewController.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 21.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

import UIKit
import Observable

class StoryViewController: UIViewController {
    
    @IBOutlet private var collectionViewStoryGroups: UICollectionView!
    
    private var disposal = Disposal()
    
    let viewModel = StoryContentVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Instagram"
        configureCollectionView()
        observeStories()
        fetchStories()
    }
    
    private func configureCollectionView() {
        collectionViewStoryGroups.delegate = self
        collectionViewStoryGroups.dataSource = self
        collectionViewStoryGroups.register(UINib(nibName: StoryGroupCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: StoryGroupCollectionViewCell.identifier)
    }
    
    private func observeStories() {
        viewModel.storyContent.observe { [weak self] (_, _) in
            self?.collectionViewStoryGroups.reloadData()
        }.add(to: &disposal)
    }
    
    private func fetchStories() {
        viewModel.fetchStories()
    }
}

extension StoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfGroups
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryGroupCollectionViewCell.identifier, for: indexPath) as! StoryGroupCollectionViewCell
        cell.viewModel = viewModel.getStoryGroupVM(indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let storyDetailVC = storyboard.instantiateViewController(withIdentifier: "StoryDetailViewController") as! StoryDetailViewController
        storyDetailVC.viewModel = viewModel
        storyDetailVC.scrollIndex = indexPath.row
        present(storyDetailVC, animated: true, completion: nil)
    }
    
}

