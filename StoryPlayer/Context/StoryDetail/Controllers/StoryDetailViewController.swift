//
//  StoryDetailViewController.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 22.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

import UIKit
import AVFoundation
import AnimatedCollectionViewLayout

class StoryDetailViewController: UIViewController {

    @IBOutlet private var collectionViewStories: UICollectionView!
        
    var viewModel = StoryContentVM()
    var scrollIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureScrollIndex()
        try! AVAudioSession.sharedInstance().setCategory(.playback)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentDisplayCell?.resetItems()
    }
    
    private func configureCollectionView() {
        collectionViewStories.delegate = self
        collectionViewStories.dataSource = self
        collectionViewStories.register(UINib(nibName: StoryCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: StoryCollectionViewCell.identifier)
        let layout = AnimatedCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.animator = CubeAttributesAnimator()
        collectionViewStories.collectionViewLayout = layout
    }
    
    private func configureScrollIndex() {
        viewModel.currentGroupIndex = scrollIndex
        mainThread(0.1) {
            self.scrollToCollectionView(self.viewModel.currentGroupIndex, false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        viewModel.currentGroupIndex = Int(collectionViewStories.contentOffset.x / collectionViewStories.frame.width)
        currentDisplayCell?.continueTimer()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentDisplayCell?.stopTimer()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        currentDisplayCell?.continueTimer()
    }
    
    private func scrollToCollectionView(_ index: Int,_ animate: Bool = true) {
        collectionViewStories.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animate)
    }
    
    var currentDisplayCell: StoryCollectionViewCell? {
        guard let cell = collectionViewStories.cellForItem(at: IndexPath(item: viewModel.currentGroupIndex, section: 0)) as? StoryCollectionViewCell else { return nil}
        return cell
    }
}

extension StoryDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfGroups
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.identifier, for: indexPath) as! StoryCollectionViewCell
        cell.viewModel = viewModel.getStoryGroupVM(indexPath.row)
        cell.delegate = self
        cell.continueTimer()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    //Allttaki 3 method, cubic transform icin gerekli.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
         return .zero
     }
        
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return 0
     }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //video oynarken diger cell'e gecildiginde eski celldeki videoyu durdurur.
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? StoryCollectionViewCell {
            cell.resetItems()
        }
    }
    
}

extension StoryDetailViewController: StoryCollectionViewCellDelegate {
    
    func goToNextStory() {
        viewModel.currentGroupIndex += 1
        if viewModel.currentGroupIndex == viewModel.numberOfGroups {
            self.navigationController?.popViewController(animated: true)
        } else {
            scrollToCollectionView(viewModel.currentGroupIndex)
        }
    }
    
    func goToPreviousStory() {
        if viewModel.currentGroupIndex != 0 {
            viewModel.currentGroupIndex -= 1
            scrollToCollectionView(viewModel.currentGroupIndex)
        }
    }

}

