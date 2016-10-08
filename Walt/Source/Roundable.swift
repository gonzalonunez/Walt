//
//  Roundable.swift
//  Pods
//
//  Created by Gonzalo Nunez on 10/7/16.
//
//

import Foundation

protocol Roundable {
  associatedtype RoundableData
  func rounded(to r: RoundableData) -> Self
}


extension CGFloat: Roundable {
  typealias RoundableData = CGFloat
  
  func rounded(to r: RoundableData) -> CGFloat {
    return r * floor((self/r)+0.5)
  }
  
}

extension CGSize: Roundable {
  typealias RoundableData = CGFloat
  
  func rounded(to r: RoundableData) -> CGSize {
    return CGSize(width: width.rounded(to: r), height: height.rounded(to: r))
  }
  
}
