//
//  CMSampleBuffer+ImageConvertible.swift
//  Pods
//
//  Created by Gonzalo Nunez on 10/7/16.
//
//

import UIKit
import CoreMedia

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

