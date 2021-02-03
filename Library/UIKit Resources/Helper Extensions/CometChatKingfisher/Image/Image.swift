



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


#if os(macOS)
import AppKit
private var imagesKey: Void?
private var durationKey: Void?
#else
import UIKit
import MobileCoreServices
private var imageSourceKey: Void?
#endif

#if !os(watchOS)
import CoreImage
#endif

import CoreGraphics
import ImageIO

private var animatedImageDataKey: Void?

// MARK: - Image Properties
extension CometChatKingfisherWrapper where Base: CFCrossPlatformImage {
    private(set) var animatedImageData: Data? {
        get { return getAssociatedObject(base, &animatedImageDataKey) }
        set { setRetainedAssociatedObject(base, &animatedImageDataKey, newValue) }
    }
    
    #if os(macOS)
    var cgImage: CGImage? {
        return base.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    var scale: CGFloat {
        return 1.0
    }
    
    private(set) var images: [CFCrossPlatformImage]? {
        get { return getAssociatedObject(base, &imagesKey) }
        set { setRetainedAssociatedObject(base, &imagesKey, newValue) }
    }
    
    private(set) var duration: TimeInterval {
        get { return getAssociatedObject(base, &durationKey) ?? 0.0 }
        set { setRetainedAssociatedObject(base, &durationKey, newValue) }
    }
    
    var size: CGSize {
        return base.representations.reduce(.zero) { size, rep in
            let width = max(size.width, CGFloat(rep.pixelsWide))
            let height = max(size.height, CGFloat(rep.pixelsHigh))
            return CGSize(width: width, height: height)
        }
    }
    #else
    var cgImage: CGImage? { return base.cgImage }
    var scale: CGFloat { return base.scale }
    var images: [CFCrossPlatformImage]? { return base.images }
    var duration: TimeInterval { return base.duration }
    var size: CGSize { return base.size }
    
    private(set) var imageSource: CGImageSource? {
        get { return getAssociatedObject(base, &imageSourceKey) }
        set { setRetainedAssociatedObject(base, &imageSourceKey, newValue) }
    }
    #endif

    // Bitmap memory cost with bytes.
    var cost: Int {
        let pixel = Int(size.width * size.height * scale * scale)
        guard let cgImage = cgImage else {
            return pixel * 4
        }
        return pixel * cgImage.bitsPerPixel / 8
    }
}

// MARK: - Image Conversion
extension CometChatKingfisherWrapper where Base: CFCrossPlatformImage {
    #if os(macOS)
    static func image(cgImage: CGImage, scale: CGFloat, refImage: CFCrossPlatformImage?) -> CFCrossPlatformImage {
        return CFCrossPlatformImage(cgImage: cgImage, size: .zero)
    }
    
    /// Normalize the image. This getter does nothing on macOS but return the image itself.
     var normalized: CFCrossPlatformImage { return base }

    #else
    /// Creating an image from a give `CGImage` at scale and orientation for refImage. The method signature is for
    /// compatibility of macOS version.
    static func image(cgImage: CGImage, scale: CGFloat, refImage: CFCrossPlatformImage?) -> CFCrossPlatformImage {
        return CFCrossPlatformImage(cgImage: cgImage, scale: scale, orientation: refImage?.imageOrientation ?? .up)
    }
    
    /// Returns normalized image for current `base` image.
    /// This method will try to redraw an image with orientation and scale considered.
     var normalized: CFCrossPlatformImage {
        // prevent animated image (GIF) lose it's images
        guard images == nil else { return base.copy() as! CFCrossPlatformImage }
        // No need to do anything if already up
        guard base.imageOrientation != .up else { return base.copy() as! CFCrossPlatformImage }

        return draw(to: size, inverting: true, refImage: CFCrossPlatformImage()) {
            fixOrientation(in: $0)
            return true
        }
    }

    func fixOrientation(in context: CGContext) {

        var transform = CGAffineTransform.identity

        let orientation = base.imageOrientation

        switch orientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: .pi / -2.0)
        case .up, .upMirrored:
            break
        #if compiler(>=5)
        @unknown default:
            break
        #endif
        }

        //Flip image one more time if needed to, this is to prevent flipped image
        switch orientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        #if compiler(>=5)
        @unknown default:
            break
        #endif
        }

        context.concatenate(transform)
        switch orientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
    }
    #endif
}

// MARK: - Image Representation
extension CometChatKingfisherWrapper where Base: CFCrossPlatformImage {
    /// Returns PNG representation of `base` image.
    ///
    /// - Returns: PNG data of image.
     func pngRepresentation() -> Data? {
        #if os(macOS)
            guard let cgImage = cgImage else {
                return nil
            }
            let rep = NSBitmapImageRep(cgImage: cgImage)
            return rep.representation(using: .png, properties: [:])
        #else
            #if swift(>=4.2)
            return base.pngData()
            #else
            return UIImagePNGRepresentation(base)
            #endif
        #endif
    }

    /// Returns JPEG representation of `base` image.
    ///
    /// - Parameter compressionQuality: The compression quality when converting image to JPEG data.
    /// - Returns: JPEG data of image.
     func jpegRepresentation(compressionQuality: CGFloat) -> Data? {
        #if os(macOS)
            guard let cgImage = cgImage else {
                return nil
            }
            let rep = NSBitmapImageRep(cgImage: cgImage)
            return rep.representation(using:.jpeg, properties: [.compressionFactor: compressionQuality])
        #else
            #if swift(>=4.2)
            return base.jpegData(compressionQuality: compressionQuality)
            #else
            return UIImageJPEGRepresentation(base, compressionQuality)
            #endif
        #endif
    }

    /// Returns GIF representation of `base` image.
    ///
    /// - Returns: Original GIF data of image.
     func gifRepresentation() -> Data? {
        return animatedImageData
    }

    /// Returns a data representation for `base` image, with the `format` as the format indicator.
    ///
    /// - Parameter format: The format in which the output data should be. If `unknown`, the `base` image will be
    ///                     converted in the PNG representation.
    /// - Returns: The output data representing.
     func data(format: ImageFormat) -> Data? {
        return autoreleasepool { () -> Data? in
            let data: Data?
            switch format {
            case .PNG: data = pngRepresentation()
            case .JPEG: data = jpegRepresentation(compressionQuality: 1.0)
            case .GIF: data = gifRepresentation()
            case .unknown: data = normalized.cf.pngRepresentation()
            }
            
            return data
        }
    }
}

// MARK: - Creating Images
extension CometChatKingfisherWrapper where Base: CFCrossPlatformImage {

    /// Creates an animated image from a given data and options. Currently only GIF data is supported.
    ///
    /// - Parameters:
    ///   - data: The animated image data.
    ///   - options: Options to use when creating the animated image.
    /// - Returns: An `Image` object represents the animated image. It is in form of an array of image frames with a
    ///            certain duration. `nil` if anything wrong when creating animated image.
     static func animatedImage(data: Data, options: ImageCreatingOptions) -> CFCrossPlatformImage? {
        let info: [String: Any] = [
            kCGImageSourceShouldCache as String: true,
            kCGImageSourceTypeIdentifierHint as String: kUTTypeGIF
        ]
        
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, info as CFDictionary) else {
            return nil
        }
        
        #if os(macOS)
        guard let animatedImage = GIFAnimatedImage(from: imageSource, for: info, options: options) else {
            return nil
        }
        var image: CFCrossPlatformImage?
        if options.onlyFirstFrame {
            image = animatedImage.images.first
        } else {
            image = CFCrossPlatformImage(data: data)
            var kf = image?.kf
            kf?.images = animatedImage.images
            kf?.duration = animatedImage.duration
        }
        image?.kf.animatedImageData = data
        return image
        #else
        
        var image: CFCrossPlatformImage?
        if options.preloadAll || options.onlyFirstFrame {
            // Use `images` image if you want to preload all animated data
            guard let animatedImage = GIFAnimatedImage(from: imageSource, for: info, options: options) else {
                return nil
            }
            if options.onlyFirstFrame {
                image = animatedImage.images.first
            } else {
                let duration = options.duration <= 0.0 ? animatedImage.duration : options.duration
                image = .animatedImage(with: animatedImage.images, duration: duration)
            }
            image?.cf.animatedImageData = data
        } else {
            image = CFCrossPlatformImage(data: data, scale: options.scale)
            var cf = image?.cf
            cf?.imageSource = imageSource
            cf?.animatedImageData = data
        }
        
        return image
        #endif
    }

    /// Creates an image from a given data and options. `.JPEG`, `.PNG` or `.GIF` is supported. For other
    /// image format, image initializer from system will be used. If no image object could be created from
    /// the given `data`, `nil` will be returned.
    ///
    /// - Parameters:
    ///   - data: The image data representation.
    ///   - options: Options to use when creating the image.
    /// - Returns: An `Image` object represents the image if created. If the `data` is invalid or not supported, `nil`
    ///            will be returned.
     static func image(data: Data, options: ImageCreatingOptions) -> CFCrossPlatformImage? {
        var image: CFCrossPlatformImage?
        switch data.cf.imageFormat {
        case .JPEG:
            image = CFCrossPlatformImage(data: data, scale: options.scale)
        case .PNG:
            image = CFCrossPlatformImage(data: data, scale: options.scale)
        case .GIF:
            image = CometChatKingfisherWrapper.animatedImage(data: data, options: options)
        case .unknown:
            image = CFCrossPlatformImage(data: data, scale: options.scale)
        }
        return image
    }
    
    /// Creates a downsampled image from given data to a certain size and scale.
    ///
    /// - Parameters:
    ///   - data: The image data contains a JPEG or PNG image.
    ///   - pointSize: The target size in point to which the image should be downsampled.
    ///   - scale: The scale of result image.
    /// - Returns: A downsampled `Image` object following the input conditions.
    ///
    /// - Note:
    /// Different from image `resize` methods, downsampling will not render the original
    /// input image in pixel format. It does downsampling from the image data, so it is much
    /// more memory efficient and friendly. Choose to use downsampling as possible as you can.
    ///
    /// The input size should be smaller than the size of input image. If it is larger than the
    /// original image size, the result image will be the same size of input without downsampling.
     static func downsampledImage(data: Data, to pointSize: CGSize, scale: CGFloat) -> CFCrossPlatformImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        return CometChatKingfisherWrapper.image(cgImage: downsampledImage, scale: scale, refImage: nil)
    }
}
