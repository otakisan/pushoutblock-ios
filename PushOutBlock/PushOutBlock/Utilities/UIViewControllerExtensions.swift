//
//  UIViewControllerExtensions.swift
//  PushOutBlock
//
//  Created by takashi on 2016/05/29.
//  Copyright © 2016年 Takashi Ikeda. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func initAnalysisTracker(screenName : String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: screenName)
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
    }
}