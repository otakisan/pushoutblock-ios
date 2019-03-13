//
//  GameViewController.swift
//  PushOutBlock
//
//  Created by takashi on 2016/05/29.
//  Copyright (c) 2016年 Takashi Ikeda. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

class GameViewController: UIViewController {
    
    var isShowAd = false
    var interstitial : GADInterstitial?
    var prevDidClearTime = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadAd()

        if let scene = GameScene(fileNamed:"GameScene") {
            scene.gameSceneDelegate = self
            
            // Configure the view.
            let skView = self.view as! SKView
//            skView.showsFPS = true
//            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initAnalysisTracker(screenName: "ゲームプレイ")
        
        self.showAd()
    }
    
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc private func reloadAd() {
        self.loadAd()
    }
    
    private func loadAd() {
        self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-3119454746977531/4383253606")
        let gadRequest = GADRequest()
        self.interstitial?.load(gadRequest)
        self.interstitial?.delegate = self
    }
    
    private func showAd() {
        if self.isShowAd && self.interstitial!.isReady {
            self.interstitial?.present(fromRootViewController: self)
        }
    }
}

extension GameViewController : GADInterstitialDelegate {
    func interstitialDidDismissScreen(ad: GADInterstitial!){
        self.loadAd()
    }
    
    func interstitialWillPresentScreen(ad: GADInterstitial!) {
        self.isShowAd = false
    }
    
    func interstitial(ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!){
        print(error)
        Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(GameViewController.reloadAd), userInfo: nil, repeats: true)
    }
}

extension GameViewController : GameSceneDelegate {
    func didClear() {
        let now = NSDate()
        let interval = now.timeIntervalSince(self.prevDidClearTime as Date)
        if interval > 60 {
            self.isShowAd = true
            self.showAd()
            self.prevDidClearTime = now
        }
        
    }
}
