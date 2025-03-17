//
//  VideoMaker.swift
//  TimeLapseApp
//
//  Created by Z1 on 27.01.2025.
//

import AVFoundation
import CoreImage

class VideoMaker {
    private var writer: AVAssetWriter?
    private var writerInput: AVAssetWriterInput?
    private var adaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var pixelBufferPool: CVPixelBufferPool?
    private var frameCount = 0
    private var fps: Int = 30
    private var outputURL: URL?
    private var videoSize: CGSize = .zero

    func configure(size: CGSize = CGSize(width: 4032, height: 3024), fps: Int = 30, completion: @escaping (Bool) -> Void) {
        self.fps = fps
        self.videoSize = size
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.outputURL = documentsDirectory.appendingPathComponent("timelapse_\(Date().timeIntervalSince1970).mov")

        let poolAttrs = [
            kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey: Int(size.width),
            kCVPixelBufferHeightKey: Int(size.height),
            kCVPixelBufferMetalCompatibilityKey: true,
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as [CFString: Any]

        var pool: CVPixelBufferPool?
        let poolStatus = CVPixelBufferPoolCreate(kCFAllocatorDefault, nil, poolAttrs as CFDictionary, &pool)
        guard poolStatus == kCVReturnSuccess, let createdPool = pool else {
            completion(false)
            return
        }
        self.pixelBufferPool = createdPool

        do {
            let writer = try AVAssetWriter(outputURL: outputURL!, fileType: .mov)
            let settings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: size.width,
                AVVideoHeightKey: size.height,
                AVVideoCompressionPropertiesKey: [
                    AVVideoAverageBitRateKey: 5_000_000,
                    AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel
                ]
            ]

            let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            writerInput.expectsMediaDataInRealTime = true

            let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: poolAttrs as [String: Any])

            writer.add(writerInput)
            writer.startWriting()
            writer.startSession(atSourceTime: .zero)

            self.writer = writer
            self.writerInput = writerInput
            self.adaptor = adaptor
            self.frameCount = 0

            completion(true)
        } catch {
            completion(false)
        }
    }

    func newFrame(image: CGImage) {
        guard let writer = writer, let writerInput = writerInput, let adaptor = adaptor, let pool = pixelBufferPool else {
            print("Video maker is not configured")
            return
        }

        if writer.status != .writing || !writerInput.isReadyForMoreMediaData {
            return
        }

        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &pixelBuffer)

        guard let buffer = pixelBuffer else {
            print("Failed to create pixel buffer")
            return
        }

        CVPixelBufferLockBaseAddress(buffer, [])

        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(videoSize.width),
            height: Int(videoSize.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        )

        context?.draw(image, in: CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height))
        CVPixelBufferUnlockBaseAddress(buffer, [])

        let frameTime = CMTime(value: Int64(frameCount), timescale: Int32(fps))
        adaptor.append(buffer, withPresentationTime: frameTime)
        frameCount += 1
    }

    func finish() {
        guard let writer = writer, let writerInput = writerInput else {
            return
        }

        writerInput.markAsFinished()
        writer.finishWriting {
            let url = writer.status == .completed ? self.outputURL : nil
            self.cleanup()
        }
    }

    func cleanup() {
        writer = nil
        writerInput = nil
        adaptor = nil
        pixelBufferPool = nil
        frameCount = 0
        outputURL = nil
    }
}
