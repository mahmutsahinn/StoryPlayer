//
//  StoryCollectionViewCell.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 22.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

import UIKit
import AVFoundation

protocol StoryCollectionViewCellDelegate: AnyObject {
    func goToNextStory()
    func goToPreviousStory()
}

class StoryCollectionViewCell: UICollectionViewCell {

    static let identifier = "StoryCollectionViewCell"

    @IBOutlet private var imageViewThumb: UIImageView!
    @IBOutlet private var collectionViewBars: UICollectionView!
    @IBOutlet private var viewVideo: UIView!
    @IBOutlet private var loading: UIActivityIndicatorView!
    
    var isResizingLeftEdge:Bool = false
    var isResizingRightEdge:Bool = false
    var kResizeThumbSize:CGFloat = 44.0
    
    weak var delegate: StoryCollectionViewCellDelegate?
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        collectionViewBars.delegate = self
        collectionViewBars.dataSource = self
        collectionViewBars.register(UINib(nibName: StoryBarCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: StoryBarCollectionViewCell.identifier)
    }
    
    var viewModel: StoryGroupVM! {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        collectionViewBars.reloadData()
        resetTimerAndStart()
    }
    
    var timer = Timer()
    var currentTime: CGFloat = 0
    var interval: CGFloat = 0.02
    var isPaused = false
    var touchesEnded = true
    
    private func resetTimerAndStart() {
        resetItems()
        if viewModel.currentIndex == viewModel.numberOfStories {
            delegate?.goToNextStory()
        } else {
            viewVideo.isHidden = !viewModel.getStoryItemVM(viewModel.currentIndex).isVideo
            loading.startAnimating()
            if viewModel.getStoryItemVM(viewModel.currentIndex).isVideo,
                let videoURL = URL(string: viewModel.getStoryItemVM(viewModel.currentIndex).mediaUrl) {
                let playerItem = AVPlayerItem(url: videoURL)
                player = AVPlayer(playerItem: playerItem)
                playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
                playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
                playerLayer = AVPlayerLayer(player: player)
                playerLayer?.frame = self.viewVideo.bounds
                self.viewVideo.layer.addSublayer(playerLayer!)
            } else {
                imageViewThumb.setImageURL(viewModel.getStoryItemVM(viewModel.currentIndex).mediaUrl) {
                    mainThread {
                        self.loading.stopAnimating()
                        self.isPaused = false
                    }
                }
            }
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        }
    }
    
    func resetItems() {
        timer.invalidate()
        currentTime = 0
        player?.pause()
        isPaused = true
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let playerItem = object as? AVPlayerItem, playerItem == player?.currentItem {
            if keyPath == "playbackBufferEmpty" {
                if playerItem.isPlaybackBufferEmpty {
                    mainThread {
                        self.stopTimer()
                        self.loading.startAnimating()
                    }
                }
            } else if keyPath == "playbackLikelyToKeepUp" {
                if playerItem.isPlaybackLikelyToKeepUp {
                    mainThread {
                        self.loading.stopAnimating()
                        if self.touchesEnded {
                            self.continueTimer()
                        }
                    }
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            isResizingLeftEdge = (currentPoint.x < kResizeThumbSize)
            isResizingRightEdge = (self.bounds.size.width - currentPoint.x < kResizeThumbSize)
        }
        stopTimer()
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
        isPaused = false
        if let player = player {
            player.play()
        }
    }
    
    func stopTimer() {
        isPaused = true
        if let player = player {
            player.pause()
        }
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
        cell.percentage = 0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / CGFloat(viewModel.numberOfStories) - 12), height: collectionView.frame.height)
    }
}
