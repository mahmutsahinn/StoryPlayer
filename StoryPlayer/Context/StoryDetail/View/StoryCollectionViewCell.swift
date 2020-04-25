//
//  StoryCollectionViewCell.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 22.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

import UIKit
import Observable

protocol StoryCollectionViewCellDelegate: AnyObject {
    func goToNextStory()
    func goToPreviousStory()
    func currentIndex(_ index: Int,_ groupIndex: Int)
}

class StoryCollectionViewCell: UICollectionViewCell {

    static let identifier = "StoryCollectionViewCell"

    @IBOutlet private var imageViewThumb: UIImageView!
    @IBOutlet private var collectionViewBars: UICollectionView!
    @IBOutlet private var viewVideo: VideoView!
    @IBOutlet private var loading: UIActivityIndicatorView!
    
    var isResizingLeftEdge:Bool = false
    var isResizingRightEdge:Bool = false
    var kResizeThumbSize:CGFloat = 44.0
    
    var groupIndex = 0
    
    weak var delegate: StoryCollectionViewCellDelegate?
    private var disposal = Disposal()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
        observeVideoView()
    }
    
    var viewModel: StoryGroupVM! {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        mainThread(0.1) {
            self.collectionViewBars.reloadData()
            self.resetTimerAndStart()
        }
    }
    
    private func configureCollectionView() {
        collectionViewBars.delegate = self
        collectionViewBars.dataSource = self
        collectionViewBars.register(UINib(nibName: StoryBarCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: StoryBarCollectionViewCell.identifier)
    }
    
    private func observeVideoView() {
        viewVideo.readyToPlayVideo.observe { [weak self] (_, _) in
            if self?.viewVideo.readyToPlayVideo.wrappedValue ?? false {
                self?.continueTimer()
            } else {
                self?.loading.startAnimating()
                self?.pauseTimer()
            }
        }.add(to: &disposal)
    }
    
    var timer = Timer()
    var currentTime: CGFloat = 0
    var interval: CGFloat = 0.02
    var isPaused = false
    var touchesEnded = true
    
    func resetTimerAndStart() {
        resetItems()
        if viewModel.currentIndex == viewModel.numberOfStories {
            delegate?.goToNextStory()
        } else {
            delegate?.currentIndex(viewModel.currentIndex, groupIndex)
            viewVideo.isHidden = !viewModel.getStoryItemVM(viewModel.currentIndex).isVideo
            loading.startAnimating()
            if viewModel.getStoryItemVM(viewModel.currentIndex).isVideo {
                viewVideo.videoUrl = viewModel.getStoryItemVM(viewModel.currentIndex).mediaUrl
            } else {
                imageViewThumb.setImageURL(viewModel.getStoryItemVM(viewModel.currentIndex).mediaUrl) {
                    mainThread {
                        self.continueTimer()
                    }
                }
            }
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        }
    }
    
    func resetItems() {
        timer.invalidate()
        currentTime = 0
        isPaused = true
        viewVideo.resetItems()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            isResizingLeftEdge = (currentPoint.x < kResizeThumbSize)
            isResizingRightEdge = (self.bounds.size.width - currentPoint.x < kResizeThumbSize)
        }
        pauseTimer()
        touchesEnded = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isResizingLeftEdge {
            setBarPercentage(viewModel.currentIndex, 0)
            if viewModel.currentIndex != 0 {
                viewModel.currentIndex -= 1
                setBarPercentage(viewModel.currentIndex, 0)
            } else {
                delegate?.goToPreviousStory()
            }
            resetTimerAndStart()
        } else if isResizingRightEdge {
            setBarPercentage(viewModel.currentIndex, 100)
            viewModel.currentIndex += 1
            resetTimerAndStart()
        } else {
            continueTimer()
        }
        touchesEnded = true
    }
    
    func continueTimer() {
        loading.stopAnimating()
        isPaused = false
        viewVideo.play()
    }
    
    func pauseTimer() {
        isPaused = true
        viewVideo.pause()
    }
    
    @objc private func updateTime() {
        if !isPaused {
            let duration = CGFloat(viewModel.getStoryItemVM(viewModel.currentIndex).duration)
            if currentTime > duration {
                viewModel.currentIndex += 1
                resetTimerAndStart()
            } else {
                currentTime += interval
                imageViewThumb.setImageURL(viewModel.getStoryItemVM(viewModel.currentIndex).mediaUrl)
                setBarPercentage(viewModel.currentIndex, (currentTime / duration) * 100)
            }
        }
    }
    
    private func setBarPercentage(_ index: Int,_ percentage: CGFloat) {
        if let cell = collectionViewBars.cellForItem(at: IndexPath(item: index, section: 0)) as? StoryBarCollectionViewCell {
            cell.percentage = percentage
        }
    }

}

extension StoryCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfStories
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryBarCollectionViewCell.identifier, for: indexPath) as! StoryBarCollectionViewCell
        cell.barWidth = Int(UIScreen.main.bounds.width) / viewModel.numberOfStories
        cell.percentage = indexPath.row < viewModel.currentIndex ? 100 : 0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {        
        return CGSize(width: Int(UIScreen.main.bounds.width) / viewModel.numberOfStories, height: Int(collectionView.frame.height))
    }
}
