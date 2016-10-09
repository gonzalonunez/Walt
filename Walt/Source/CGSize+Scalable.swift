//
//  CGSize+Scalable.swift
//  Pods
//
//  Created by Gonzalo Nunez on 10/9/16.
//
//

import Foundation

public protocol Scalable {
  associatedtype DataType
  mutating func scale(by factor: DataType)
  func scaled(by factor: DataType) -> Self
}

extension CGSize: Scalable {
  public typealias DataType = CGFloat
  
  public mutating func scale(by factor: DataType) {
    width = width*factor
    height = height*factor
  }
  
  public func scaled(by factor: DataType) -> CGSize {
    var copy = self
    copy.scale(by: factor)
    return copy
  }
}
