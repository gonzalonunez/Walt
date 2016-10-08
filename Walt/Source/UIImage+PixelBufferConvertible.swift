//
//  UIImage+PixelBufferConvertible.swift
//  Pods
//
//  Created by Gonzalo Nunez on 10/7/16.
//
//

import UIKit
import AVFoundation

public protocol PixelBufferConvertible {
  var pixelBufferSize: CGSize { get }
  func toPixelBuffer() -> CVPixelBuffer?
}

extension UIImage: PixelBufferConvertible {
  
  public var pixelBufferSize: CGSize {
    if size.width > 1280 || size.height > 1280 {
      let maxRect = (size.width > size.height) ? CGRect(x: 0, y: 0, width: 720, height: 1280) : CGRect(x: 0, y: 0, width: 1280, height: 720)
      let aspectRect = AVMakeRect(aspectRatio: size, insideRect: maxRect)
      return aspectRect.size.rounded(to: 16)
    } else {
      return size.rounded(to: 16)
    }
  }
  
  public func toPixelBuffer() -> CVPixelBuffer? {
    
    defer {
      pxBufferPtr.deinitialize()
    }
    
    let options = [kCVPixelBufferCGImageCompatibilityKey as String : NSNumber(value: true),
                   kCVPixelBufferCGBitmapContextCompatibilityKey as String : NSNumber(value: true)] as CFDictionary
    
    let bufferSize = pixelBufferSize
    
    var pxBufferPtr = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
    CVPixelBufferCreate(kCFAllocatorDefault, Int(bufferSize.width), Int(bufferSize.height), kCVPixelFormatType_32ARGB, options, pxBufferPtr)
    
    guard let pxBuffer = pxBufferPtr.pointee else {
      return nil
    }
    
    CVPixelBufferLockBaseAddress(pxBuffer, [])
    
    let baseAddress = CVPixelBufferGetBaseAddress(pxBuffer)
    let bytesPerRow = bufferSize.width*4
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    guard let context = CGContext(data: baseAddress, width: Int(bufferSize.width), height: Int(bufferSize.height),
                                  bitsPerComponent: 8, bytesPerRow: Int(bytesPerRow), space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
      else {
        return nil
    }
    
    guard let cgImage = cgImage else {
      return nil
    }
    
    let rect = CGRect(origin: .zero, size: bufferSize)
    
    context.setFillColor(UIColor.white.cgColor)
    context.fill(rect)
    context.interpolationQuality = .high
    
    context.draw(cgImage, in: rect)
    
    CVPixelBufferUnlockBaseAddress(pxBuffer, [])
    
    return pxBuffer
  }
  
}
