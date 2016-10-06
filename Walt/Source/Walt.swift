//
//  Walt.swift
//  Pods
//
//  Created by Gonzalo Nunez on 10/3/16.
//
//

import Foundation

import AVFoundation
import CoreMedia
import CoreVideo
import ImageIO
import MobileCoreServices

//MARK: CMSampleBuffer + ImageConvertible

public protocol ImageConvertible {
  func toImage() -> UIImage?
}

extension CMSampleBuffer: ImageConvertible {
  
  public func toImage() -> UIImage? {
    
    guard let imageBuffer = CMSampleBufferGetImageBuffer(self) else {
      return nil
    }
    
    CVPixelBufferLockBaseAddress(imageBuffer, [])
    
    let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
    
    let width = CVPixelBufferGetWidth(imageBuffer)
    let height = CVPixelBufferGetHeight(imageBuffer)
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    guard let context = CGContext(data: baseAddress, width: width, height: height,
                                  bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace,
                                  bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
    else {
      return nil
    }
    
    guard let cgImage = context.makeImage() else {
      return nil
    }
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, [])
    
    return UIImage(cgImage: cgImage)
  }
  
}

//MARK: UIImage + PixelBufferConvertible

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

//MARK: Helpers

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

