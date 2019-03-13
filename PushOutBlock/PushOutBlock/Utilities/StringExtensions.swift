//
//  StringExtensions.swift
//  PushOutBlock
//
//  Created by takashi on 2016/05/29.
//  Copyright © 2016年 Takashi Ikeda. All rights reserved.
///
import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(args : [String]) -> String {
        return String(format: self.localized(), arguments: args)
    }
}
