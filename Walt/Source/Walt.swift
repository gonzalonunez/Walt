//
//  Walt.swift
//  Pods
//
//  Created by Gonzalo Nunez on 10/3/16.
//
//

import AVFoundation

public typealias MovieCompletionBlock = (URL, NSData?) -> Void

public enum MovieError: Error {
  case noImages
  case fileExists
}

public enum Walt {
  
  fileprivate static let k2500kbps = 2500 * 1000
  fileprivate static let kVideoQueue = DispatchQueue(label: "com.ZenunSoftware.Walt.VideoQueue")
  
  public static func writeMovie(with images: [UIImage],
                                loopDuration: TimeInterval,
                                duration: Int = 10,
                                shouldOverwrite: Bool = true,
                                completion: @escaping MovieCompletionBlock) throws
  {
    let path = NSString.path(withComponents: [NSTemporaryDirectory(), "Movie.MOV"])
    let url = URL(fileURLWithPath: path)
    return try writeMovie(with: images, loopDuration: loopDuration, duration: duration, url: url, completion: completion)
  }
  
  public static func writeMovie(with images: [UIImage],
                                loopDuration: TimeInterval,
                                duration: Int = 10,
                                url: URL,
                                shouldOverwrite: Bool = true,
                                completion: @escaping MovieCompletionBlock) throws
  {
    if images.count < 2 {
      throw MovieError.noImages
    }
    
    if (FileManager.default.fileExists(atPath: url.path) && shouldOverwrite) {
      try FileManager.default.removeItem(atPath: url.path)
    } else {
      throw MovieError.fileExists
    }
    
    let assetWriter = try AVAssetWriter(url: url, fileType: AVFileTypeQuickTimeMovie)
    
    let frameSize = images[0].pixelBufferSize
    let iterations = duration/Int(loopDuration)
    let fps = images.count/Int(loopDuration)
    
    let outputSettings: [String : Any] = [AVVideoCodecKey: AVVideoCodecH264,
                                          AVVideoWidthKey: frameSize.width,
                                          AVVideoHeightKey: frameSize.height,
                                          AVVideoScalingModeKey: AVVideoScalingModeResizeAspect,
                                          AVVideoCompressionPropertiesKey:[AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
                                                                           AVVideoAverageBitRateKey: Walt.k2500kbps,
                                                                           AVVideoExpectedSourceFrameRateKey: fps]]
    
    let assetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: outputSettings)
    assetWriterInput.expectsMediaDataInRealTime = true
    
    let attributes: [String : Any] = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                                      kCVPixelBufferWidthKey as String: frameSize.width,
                                      kCVPixelBufferHeightKey as String: frameSize.height,
                                      kCVPixelFormatCGBitmapContextCompatibility as String: true,
                                      kCVPixelFormatCGImageCompatibility as String: true]
    
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: attributes)
    
    assetWriter.add(assetWriterInput)
    assetWriter.startWriting()
    assetWriter.startSession(atSourceTime: kCMTimeZero)
    
    var pxBufferIndex = 0
    var dropped = 0
    
    assetWriterInput.requestMediaDataWhenReady(on: Walt.kVideoQueue) {
      
      while assetWriterInput.isReadyForMoreMediaData {
        
        if let pxBuffer = images[pxBufferIndex].toPixelBuffer() {
          adaptor.append(pxBuffer, withPresentationTime: CMTime(seconds: Double(pxBufferIndex), preferredTimescale: CMTimeScale(fps)))
        }
        
        if pxBufferIndex == images.count {
          assetWriterInput.markAsFinished()
          assetWriter.finishWriting {
            DispatchQueue.main.async {
              let data = NSData(contentsOf: url)
              completion(url, data)
            }
          }
        }
        pxBufferIndex += 1
      }
      
    }
  }
  
}

