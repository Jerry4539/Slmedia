//
//  SLVideoPlayer.swift
//  rpc
//
//  Created by = Jerry4539 on 2021/3/5.
//  Copyright © 2021 Jerry4539 . All rights reserved.
//
import UIKit
import AVKit
public class SLVideoPlayer: NSObject {
    // @Jerry4539 
    public static func presentVideoPlayerController(targetVC:UIViewController,videoURL:URL){
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        targetVC.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}
