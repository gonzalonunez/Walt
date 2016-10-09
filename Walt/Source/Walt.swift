//
//  Walt.swift
//  Pods
//
//  Created by Gonzalo Nunez on 10/3/16.
//
//

import AVFoundation

import ImageIO
import MobileCoreServices

public typealias DataCompletionBlock = (URL, Data?) -> Void

public enum WaltError: Error {
  case noImages
  case durationZero
  case fileExists
}

public struct MovieWritingOptions {
  var loopDuration: TimeInterval
  var duration: Int
  var shouldOverwrite: Bool
  
  public init(loopDuration: TimeInterval, duration: Int = 10, shouldOverwrite: Bool = true) {
    self.loopDuration = loopDuration
    self.duration = duration
    self.shouldOverwrite = shouldOverwrite
  }
}

public struct GifWritingOptions {
  var duration: TimeInterval
  var scale: CGFloat
  var gifLoop: GifLoop
  var shouldOverwrite: Bool
  var qos: DispatchQoS.QoSClass
  var skipsFailedImages: Bool
  
  public init(duration: TimeInterval, scale: CGFloat = 1, gifLoop: GifLoop = .infinite,
              shouldOverwrite: Bool = true, qos: DispatchQoS.QoSClass = .default, skipsFailedImages: Bool = true)
  {
    self.duration = duration
    self.scale = scale
    self.gifLoop = gifLoop
    self.shouldOverwrite = shouldOverwrite
    self.qos = qos
    self.skipsFailedImages = skipsFailedImages
  }
}

public enum Walt {
  
  //MARK: Movies
  
  fileprivate static let k2500kbps = 2500 * 1000
  fileprivate static let kVideoQueue = DispatchQueue(label: "com.ZenunSoftware.Walt.VideoQueue")
  
  public static func writeMovie(with images: [UIImage],
                                options: MovieWritingOptions,
                                completion: @escaping DataCompletionBlock) throws
  {
    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("com-ZenunSoftware-Walt-Movie.MOV")
    return try writeMovie(with: images, options: options, url: url, completion: completion)
  }
  
  public static func writeMovie(with images: [UIImage],
                                options: MovieWritingOptions,
                                url: URL,
                                completion: @escaping DataCompletionBlock) throws
  {
    if images.count < 2 {
      throw WaltError.noImages
    }
    
    if options.loopDuration == 0 || options.duration == 0 {
      throw WaltError.durationZero
    }
    
    if (FileManager.default.fileExists(atPath: url.path)) {
      if options.shouldOverwrite {
        try FileManager.default.removeItem(atPath: url.path)
      } else {
        throw WaltError.fileExists
      }
    }
    
    let assetWriter = try AVAssetWriter(url: url, fileType: AVFileTypeQuickTimeMovie)
    
    let frameSize = images[0].pixelBufferSize
    let iterations = Int(ceil(Double(options.duration)/options.loopDuration))
    let fps = Int(ceil(Double(images.count)/options.loopDuration))
    
    var finalVideoArray = [UIImage]()
    for i in 0...iterations {
      for image in images {
        finalVideoArray.append(image)
      }
    }
    
    let outputSettings: [String : Any] = [AVVideoCodecKey: AVVideoCodecH264,
                                          AVVideoWidthKey: frameSize.width,
                                          AVVideoHeightKey: frameSize.height,
                                          AVVideoScalingModeKey: AVVideoScalingModeResizeAspect,
                                          AVVideoCompressionPropertiesKey: [AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
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
    
    assetWriterInput.requestMediaDataWhenReady(on: Walt.kVideoQueue) {
      
      while assetWriterInput.isReadyForMoreMediaData {
        
        if pxBufferIndex < finalVideoArray.count {
          if let pxBuffer = finalVideoArray[pxBufferIndex].toPixelBuffer() {
            adaptor.append(pxBuffer, withPresentationTime: CMTime(value: CMTimeValue(pxBufferIndex), timescale: CMTimeScale(fps)))
          }
        }
        
        if pxBufferIndex == finalVideoArray.count {
          assetWriterInput.markAsFinished()
          assetWriter.finishWriting {
            DispatchQueue.main.async {
              let data = try? Data(contentsOf: url)
              completion(url, data)
            }
          }
        }
        
        pxBufferIndex += 1
      }
      
    }
  }
  
  //MARK: Gifs
  
  public static func createGif(with images: [UIImage],
                               options: GifWritingOptions,
                               completion: @escaping DataCompletionBlock) throws
  {
    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("com-ZenunSoftware-Walt-Gif.gif")
    return try createGif(with: images, options: options, url: url, completion: completion)
  }

  
  public static func createGif(with images: [UIImage],
                               options: GifWritingOptions,
                               url: URL,
                               completion: @escaping DataCompletionBlock) throws
  {
    if images.count < 2 {
      throw WaltError.noImages
    }
    
    if options.duration == 0 {
      throw WaltError.durationZero
    }
    
    if (FileManager.default.fileExists(atPath: url.path)) {
      if options.shouldOverwrite {
        try FileManager.default.removeItem(atPath: url.path)
      } else {
        throw WaltError.fileExists
      }
    }
    
    DispatchQueue.global(qos: .userInitiated).async {
      guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeGIF, images.count, nil) else {
        DispatchQueue.main.async {
          completion(url, nil)
        }
        return
      }
      
      let desiredFrameDuration = options.duration/Double(images.count)
      let clampedFrameDuration = max(0.1, desiredFrameDuration)
      
      let delayTimes = [kCGImagePropertyGIFUnclampedDelayTime as String: desiredFrameDuration,
                        kCGImagePropertyGIFDelayTime as String: clampedFrameDuration]
      
      let gifProperties = [kCGImagePropertyGIFDictionary as String: options.gifLoop.dict]
      CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
      
      let frameProperties = [kCGImagePropertyGIFDictionary as String: delayTimes]
      
      let first = images.first!
      let scaledSize = first.size.scaled(by: options.scale)
      
      for image in images {
        UIGraphicsBeginImageContext(scaledSize)
        
        defer {
          UIGraphicsEndImageContext()
        }
        
        let rect = CGRect(origin: .zero, size: scaledSize)
        image.draw(in: rect)
        
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
          if options.skipsFailedImages {
            continue
          }
          
          DispatchQueue.main.async {
            completion(url, nil)
          }
          
          return
        }
        
        CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
      }
      
      CGImageDestinationFinalize(destination)
    }
  }
  
}
