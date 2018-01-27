//
//  ComputerVision.swift
//  AiRGestures
//
//  Created by Jay Lees on 27/01/2018.
//  Copyright © 2018 Lewis Bell. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class Vision {
    static let context = CIContext()
    
    private var backgroundImage: CGImage?
    
    public func requiresRefresh() -> Bool {
        return backgroundImage == nil
    }
    
    public func setBackgroundImage(_ image: CMSampleBuffer){
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(image)!
        
        // Rotated so reversed
        let width = CVPixelBufferGetHeight(pixelBuffer)
        let height = CVPixelBufferGetWidth(pixelBuffer)
        
        self.backgroundImage = CIContext().createCGImage(CIImage(cvImageBuffer: pixelBuffer).oriented(.leftMirrored), from: CGRect(x: 0, y: 0, width: width, height: height))
        
    }
    
    public func calculateResultingBuffer(from buffer: CMSampleBuffer) -> CGImage {
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(buffer)!
        let width = CVPixelBufferGetHeight(pixelBuffer)
        let height = CVPixelBufferGetWidth(pixelBuffer)
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.leftMirrored)
        let videoImage = Vision.context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: width, height: height))
        
        var newImage = pixelValues(fromCGImage: videoImage)!
        let background = pixelValues(fromCGImage: backgroundImage!)!
        
        var output = [UInt8](repeating: 0, count: height * width)
        for y in 0..<height {
            for x in 0..<width {
                let i = width * y + x
                let r = ((newImage[i] >> 8) & 0xFF) - ((background[i] >> 8) & 0xFF)
                let g = ((newImage[i] >> 16) & 0xFF) - ((background[i] >> 16) & 0xFF)
                let b = ((newImage[i] >> 24) & 0xFF) - ((background[i] >> 24) & 0xFF)
                let rr = Double(r * r)
                let gg = Double(g * g)
                let bb = Double(b * b)
                output[i] = UInt8(sqrt ((rr + gg + bb) / 3 * 256)) << 8
                
            }
        }
        print("READ")
        let im = image(fromPixelValues: output, width: width, height: height)!
        print("WRITTEN")
        return im
    }
    
    private func pixelValues(fromCGImage imageRef: CGImage?) -> [UInt8]? {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        if let imageRef = imageRef {
            width = imageRef.width
            height = imageRef.height
            let bitsPerComponent = imageRef.bitsPerComponent
            let bitsPerPixel = imageRef.bitsPerPixel
            let bytesPerRow = imageRef.bytesPerRow
            let totalBytes = height * bytesPerRow
            
            let colorSpace = CGColorSpaceCreateDeviceGray()
            var intensities = [UInt8](repeating: 0, count: height*bytesPerRow)
            let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
            
            pixelValues = intensities
        }
        
        return pixelValues
    }
    
    func image(fromPixelValues pixelValues: [UInt8]?, width: Int, height: Int) -> CGImage?{
        var imageRef: CGImage?
        if var pixelValues = pixelValues {
            let bitsPerComponent = 8
            let bytesPerPixel = 1
            let bitsPerPixel = bytesPerPixel * bitsPerComponent
            let bytesPerRow = bytesPerPixel * width
            let totalBytes = height * bytesPerRow
            
            imageRef = withUnsafePointer(to: &pixelValues, {
                ptr -> CGImage? in
                var imageRef: CGImage?
                let colorSpaceRef = CGColorSpaceCreateDeviceGray()
                let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).union(CGBitmapInfo())
                let data = UnsafeRawPointer(ptr.pointee).assumingMemoryBound(to: UInt8.self)
                let releaseData: CGDataProviderReleaseDataCallback = {
                    (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
                }
                
                if let providerRef = CGDataProvider(dataInfo: nil, data: data, size: totalBytes, releaseData: releaseData) {
                    imageRef = CGImage(width: width,
                                       height: height,
                                       bitsPerComponent: bitsPerComponent,
                                       bitsPerPixel: bitsPerPixel,
                                       bytesPerRow: bytesPerRow,
                                       space: colorSpaceRef,
                                       bitmapInfo: bitmapInfo,
                                       provider: providerRef,
                                       decode: nil,
                                       shouldInterpolate: false,
                                       intent: CGColorRenderingIntent.defaultIntent)
                }
                
                return imageRef
            })
        }
        
        return imageRef
    }
}


