//
//  VideoView.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 24.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

import UIKit
import AVFoundation
import Observable

class VideoView: UIView {
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    let keyBuffer = "playbackBufferEmpty"
    let keyKeepUp = "playbackLikelyToKeepUp"
    
    var readyToPlayVideo = MutableObservable(false)
    
    var videoUrl: String? {
        didSet {
            createPlayer()
        }
    }
    
    private func createPlayer() {
        guard let videoUrl = videoUrl, let videoURL = URL(string: videoUrl) else { return }
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        playerItem.addObserver(self, forKeyPath: keyBuffer, options: NSKeyValueObservingOptions.new, context: nil)
        playerItem.addObserver(self, forKeyPath: keyKeepUp, options: NSKeyValueObservingOptions.new, context: nil)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = self.bounds
        self.layer.addSublayer(playerLayer!)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let playerItem = object as? AVPlayerItem, playerItem == player?.currentItem {
            if keyPath == keyBuffer {
                if playerItem.isPlaybackBufferEmpty {
                    self.readyToPlayVideo.wrappedValue = false
                }
            } else if keyPath == keyKeepUp {
                if playerItem.isPlaybackLikelyToKeepUp {
                    self.readyToPlayVideo.wrappedValue = true
                }
            }
        }
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func resetItems() {
        player?.pause()
        player?.currentItem?.removeObserver(self, forKeyPath: keyBuffer)
        player?.currentItem?.removeObserver(self, forKeyPath: keyKeepUp)
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        videoUrl = nil
    }
}
