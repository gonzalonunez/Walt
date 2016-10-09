//
//  GifLoop.swift
//  Pods
//
//  Created by Gonzalo Nunez on 10/9/16.
//
//

import Foundation
import ImageIO

public protocol DictionaryConvertible {
  associatedtype Key: Hashable
  associatedtype Value
  var dict: Dictionary<Key, Value> { get }
}

public enum GifLoop: DictionaryConvertible {
  case absolute(Int)
  static var infinite = GifLoop.absolute(0) // 0 = infinite loop for kCGImagePropertyGIFLoopCount
  
  public typealias Key = String
  public typealias Value = Int
  
  public var dict: Dictionary<Key, Value> {
    switch self {
    case .absolute(let loopCount):
      return [kCGImagePropertyGIFLoopCount as String: loopCount]
    }    
  }
}
