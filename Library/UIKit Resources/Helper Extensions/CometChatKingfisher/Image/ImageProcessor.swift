

//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


import Foundation
import CoreGraphics

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

/// Represents an item which could be processed by an `ImageProcessor`.
///
/// - image: Input image. The processor should provide a way to apply
///          processing on this `image` and return the result image.
/// - data:  Input data. The processor should provide a way to apply
///          processing on this `image` and return the result image.
 enum ImageProcessItem {
    
    /// Input image. The processor should provide a way to apply
    /// processing on this `image` and return the result image.
    case image(CFCrossPlatformImage)
    
    /// Input data. The processor should provide a way to apply
    /// processing on this `image` and return the result image.
    case data(Data)
}

/// An `ImageProcessor` would be used to convert some downloaded data to an image.
 protocol ImageProcessor {
    /// Identifier of the processor. It will be used to identify the processor when 
    /// caching and retrieving an image. You might want to make sure that processors with
    /// same properties/functionality have the same identifiers, so correct processed images
    /// could be retrieved with proper key.
    /// 
    /// - Note: Do not supply an empty string for a customized processor, which is already reserved by
    /// the `DefaultImageProcessor`. It is recommended to use a reverse domain name notation string of
    /// your own for the identifier.
    var identifier: String { get }
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: The return value should be `nil` if processing failed while converting an input item to image.
    ///         If `nil` received by the processing caller, an error will be reported and the process flow stops.
    ///         If the processing flow is not critical for your flow, then when the input item is already an image
    ///         (`.image` case) and there is any errors in the processing, you could return the input image itself
    ///         to keep the processing pipeline continuing.
    /// - Note: Most processor only supports CG-based images. watchOS is not supported for processors containing
    ///         a filter, the input image will be returned directly on watchOS.
    /// - Note:
    /// This method is deprecated. Please implement the version with
    /// `CometChatKingfisherParsedOptionsInfo` as parameter instead.
    @available(*, deprecated,
    message: "Deprecated. Implement the method with same name but with `CometChatKingfisherParsedOptionsInfo` instead.")
    func process(item: ImageProcessItem, options: CometChatKingfisherOptionsInfo) -> CFCrossPlatformImage?

    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: The parsed options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: The return value should be `nil` if processing failed while converting an input item to image.
    ///         If `nil` received by the processing caller, an error will be reported and the process flow stops.
    ///         If the processing flow is not critical for your flow, then when the input item is already an image
    ///         (`.image` case) and there is any errors in the processing, you could return the input image itself
    ///         to keep the processing pipeline continuing.
    /// - Note: Most processor only supports CG-based images. watchOS is not supported for processors containing
    ///         a filter, the input image will be returned directly on watchOS.
    func process(item: ImageProcessItem, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage?
}

extension ImageProcessor {
     func process(item: ImageProcessItem, options: CometChatKingfisherOptionsInfo) -> CFCrossPlatformImage? {
        return process(item: item, options: CometChatKingfisherParsedOptionsInfo(options))
    }
}

extension ImageProcessor {
    
    /// Appends an `ImageProcessor` to another. The identifier of the new `ImageProcessor`
    /// will be "\(self.identifier)|>\(another.identifier)".
    ///
    /// - Parameter another: An `ImageProcessor` you want to append to `self`.
    /// - Returns: The new `ImageProcessor` will process the image in the order
    ///            of the two processors concatenated.
     func append(another: ImageProcessor) -> ImageProcessor {
        let newIdentifier = identifier.appending("|>\(another.identifier)")
        return GeneralProcessor(identifier: newIdentifier) {
            item, options in
            if let image = self.process(item: item, options: options) {
                return another.process(item: .image(image), options: options)
            } else {
                return nil
            }
        }
    }
}

func ==(left: ImageProcessor, right: ImageProcessor) -> Bool {
    return left.identifier == right.identifier
}

func !=(left: ImageProcessor, right: ImageProcessor) -> Bool {
    return !(left == right)
}

typealias ProcessorImp = ((ImageProcessItem, CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage?)
struct GeneralProcessor: ImageProcessor {
    let identifier: String
    let p: ProcessorImp
    func process(item: ImageProcessItem, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        return p(item, options)
    }
}

/// The default processor. It converts the input data to a valid image.
/// Images of .PNG, .JPEG and .GIF format are supported.
/// If an image item is given as `.image` case, `DefaultImageProcessor` will
/// do nothing on it and return the associated image.
 struct DefaultImageProcessor: ImageProcessor {
    
    /// A default `DefaultImageProcessor` could be used across.
     static let default1 = DefaultImageProcessor()
    
    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     let identifier = ""
    
    /// Creates a `DefaultImageProcessor`. Use `DefaultImageProcessor.default` to get an instance,
    /// if you do not have a good reason to create your own `DefaultImageProcessor`.
     init() {}
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     func process(item: ImageProcessItem, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image.cf.scaled(to: options.scaleFactor)
        case .data(let data):
            return CometChatKingfisherWrapper.image(data: data, options: options.imageCreatingOptions)
        }
    }
}

/// Represents the rect corner setting when processing a round corner image.
 struct RectCorner: OptionSet {
    
    /// Raw value of the rect corner.
     let rawValue: Int
    
    /// Represents the top left corner.
     static let topLeft = RectCorner(rawValue: 1 << 0)
    
    /// Represents the top right corner.
     static let topRight = RectCorner(rawValue: 1 << 1)
    
    /// Represents the bottom left corner.
     static let bottomLeft = RectCorner(rawValue: 1 << 2)
    
    /// Represents the bottom right corner.
     static let bottomRight = RectCorner(rawValue: 1 << 3)
    
    /// Represents all corners.
     static let all: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    
    /// Creates a `RectCorner` option set with a given value.
    ///
    /// - Parameter rawValue: The value represents a certain corner option.
     init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    var cornerIdentifier: String {
        if self == .all {
            return ""
        }
        return "_corner(\(rawValue))"
    }
}

#if !os(macOS)
/// Processor for adding an blend mode to images. Only CG-based images are supported.
 struct BlendImageProcessor: ImageProcessor {

    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     let identifier: String

    /// Blend Mode will be used to blend the input image.
     let blendMode: CGBlendMode

    /// Alpha will be used when blend image.
     let alpha: CGFloat

    /// Background color of the output image. If `nil`, it will stay transparent.
     let backgroundColor: CFCrossPlatformColor?

    /// Creates a `BlendImageProcessor`.
    ///
    /// - Parameters:
    ///   - blendMode: Blend Mode will be used to blend the input image.
    ///   - alpha: Alpha will be used when blend image. From 0.0 to 1.0. 1.0 means solid image,
    ///            0.0 means transparent image (not visible at all). Default is 1.0.
    ///   - backgroundColor: Background color to apply for the output image. Default is `nil`.
     init(blendMode: CGBlendMode, alpha: CGFloat = 1.0, backgroundColor: CFCrossPlatformColor? = nil) {
        self.blendMode = blendMode
        self.alpha = alpha
        self.backgroundColor = backgroundColor
        var identifier = "com.onevcat.CometChatKingfisher.BlendImageProcessor(\(blendMode.rawValue),\(alpha))"
        if let color = backgroundColor {
            identifier.append("_\(color.hex)")
        }
        self.identifier = identifier
    }

    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     func process(item: ImageProcessItem, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image.cf.scaled(to: options.scaleFactor)
                        .cf.image(withBlendMode: blendMode, alpha: alpha, backgroundColor: backgroundColor)
        case .data:
            return (DefaultImageProcessor.default1 |> self).process(item: item, options: options)
        }
    }
}
#endif

#if os(macOS)
/// Processor for adding an compositing operation to images. Only CG-based images are supported in macOS.
 struct CompositingImageProcessor: ImageProcessor {

    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     let identifier: String

    /// Compositing operation will be used to the input image.
     let compositingOperation: NSCompositingOperation

    /// Alpha will be used when compositing image.
     let alpha: CGFloat

    /// Background color of the output image. If `nil`, it will stay transparent.
     let backgroundColor: CFCrossPlatformColor?

    /// Creates a `CompositingImageProcessor`
    ///
    /// - Parameters:
    ///   - compositingOperation: Compositing operation will be used to the input image.
    ///   - alpha: Alpha will be used when compositing image.
    ///            From 0.0 to 1.0. 1.0 means solid image, 0.0 means transparent image.
    ///            Default is 1.0.
    ///   - backgroundColor: Background color to apply for the output image. Default is `nil`.
     init(compositingOperation: NSCompositingOperation,
                alpha: CGFloat = 1.0,
                backgroundColor: CFCrossPlatformColor? = nil)
    {
        self.compositingOperation = compositingOperation
        self.alpha = alpha
        self.backgroundColor = backgroundColor
        var identifier = "com.onevcat.CometChatKingfisher.CompositingImageProcessor(\(compositingOperation.rawValue),\(alpha))"
        if let color = backgroundColor {
            identifier.append("_\(color.hex)")
        }
        self.identifier = identifier
    }

    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     func process(item: ImageProcessItem, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image.kf.scaled(to: options.scaleFactor)
                        .kf.image(
                            withCompositingOperation: compositingOperation,
                            alpha: alpha,
                            backgroundColor: backgroundColor)
        case .data:
            return (DefaultImageProcessor.default |> self).process(item: item, options: options)
        }
    }
}
#endif

/// Processor for making round corner images. Only CG-based images are supported in macOS, 
/// if a non-CG image passed in, the processor will do nothing.
///
/// Note: The input image will be rendered with round corner pixels removed. If the image itself does not contain
/// alpha channel (for example, a JPEG image), the processed image will contain an alpha channel in memory in order
/// to show correctly. However, when cached into disk, the image format will be respected and the alpha channel will
/// be removed. That means when you load the processed image from cache again, you will lose transparent corner.
/// You could use `FormatIndicatedCacheSerializer.png` to force CometChatKingfisher to serialize the image to PNG format in this
/// case.
 struct RoundCornerImageProcessor: ImageProcessor {
    
    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     let identifier: String

    /// Corner radius will be applied in processing.
     let cornerRadius: CGFloat
    
    /// The target corners which will be applied rounding.
     let roundingCorners: RectCorner
    
    /// Target size of output image should be. If `nil`, the image will keep its original size after processing.
     let targetSize: CGSize?

    /// Background color of the output image. If `nil`, it will use a transparent background.
     let backgroundColor: CFCrossPlatformColor?

    /// Creates a `RoundCornerImageProcessor`.
    ///
    /// - Parameters:
    ///   - cornerRadius: Corner radius will be applied in processing.
    ///   - targetSize: Target size of output image should be. If `nil`,
    ///                 the image will keep its original size after processing.
    ///                 Default is `nil`.
    ///   - corners: The target corners which will be applied rounding. Default is `.all`.
    ///   - backgroundColor: Background color to apply for the output image. Default is `nil`.
     init(
        cornerRadius: CGFloat,
        targetSize: CGSize? = nil,
        roundingCorners corners: RectCorner = .all,
        backgroundColor: CFCrossPlatformColor? = nil)
    {
        self.cornerRadius = cornerRadius
        self.targetSize = targetSize
        self.roundingCorners = corners
        self.backgroundColor = backgroundColor

        self.identifier = {
            var identifier = ""

            if let size = targetSize {
                identifier = "com.onevcat.CometChatKingfisher.RoundCornerImageProcessor" +
                             "(\(cornerRadius)_\(size)\(corners.cornerIdentifier))"
            } else {
                identifier = "com.onevcat.CometChatKingfisher.RoundCornerImageProcessor" +
                             "(\(cornerRadius)\(corners.cornerIdentifier))"
            }
            if let backgroundColor = backgroundColor {
                identifier += "_\(backgroundColor)"
            }

            return identifier
        }()
    }
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     func process(item: ImageProcessItem, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        switch item {
        case .image(let image):
            let size = targetSize ?? image.cf.size
            return image.cf.scaled(to: options.scaleFactor)
                        .cf.image(
                            withRoundRadius: cornerRadius,
                            fit: size,
                            roundingCorners: roundingCorners,
                            backgroundColor: backgroundColor)
        case .data:
            return (DefaultImageProcessor.default1 |> self).process(item: item, options: options)
        }
    }
}


/// Represents how a size adjusts itself to fit a target size.
///
/// - none: Not scale the content.
/// - aspectFit: Scales the content to fit the size of the view by maintaining the aspect ratio.
/// - aspectFill: Scales the content to fill the size of the view.
 enum ContentMode {
    /// Not scale the content.
    case none
    /// Scales the content to fit the size of the view by maintaining the aspect ratio.
    case aspectFit
    /// Scales the content to fill the size of the view.
    case aspectFill
}

/// Processor for resizing images.
/// If you need to resize a data represented image to a smaller size, use `DownsamplingImageProcessor`
/// instead, which is more efficient and takes less memory.
 struct ResizingImageProcessor: ImageProcessor {
    
    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     let identifier: String
    
    /// The reference size for resizing operation in point.
     let referenceSize: CGSize
    
    /// Target content mode of output image should be.
    /// Default is `.none`.
     let targetContentMode: ContentMode
    
    /// Creates a `ResizingImageProcessor`.
    ///
    /// - Parameters:
    ///   - referenceSize: The reference size for resizing operation in point.
    ///   - mode: Target content mode of output image should be.
    ///
    /// - Note:
    ///   The instance of `ResizingImageProcessor` will follow its `mode` property
    ///   and try to resizing the input images to fit or fill the `referenceSize`.
    ///   That means if you are using a `mode` besides of `.none`, you may get an
    ///   image with its size not be the same as the `referenceSize`.
    ///
    ///   **Example**: With input image size: {100, 200}, 
    ///   `referenceSize`: {100, 100}, `mode`: `.aspectFit`,
    ///   you will get an output image with size of {50, 100}, which "fit"s
    ///   the `referenceSize`.
    ///
    ///   If you need an output image exactly to be a specified size, append or use
    ///   a `CroppingImageProcessor`.
     init(referenceSize: CGSize, mode: ContentMode = .none) {
        self.referenceSize = referenceSize
        self.targetContentMode = mode
        
        if mode == .none {
            self.identifier = "com.onevcat.CometChatKingfisher.ResizingImageProcessor(\(referenceSize))"
        } else {
            self.identifier = "com.onevcat.CometChatKingfisher.ResizingImageProcessor(\(referenceSize), \(mode))"
        }
    }
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     func process(item: ImageProcessItem, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image.cf.scaled(to: options.scaleFactor)
                        .cf.resize(to: referenceSize, for: targetContentMode)
        case .data:
            return (DefaultImageProcessor.default1 |> self).process(item: item, options: options)
        }
    }
}

/// Processor for adding blur effect to images. `Accelerate.framework` is used underhood for 
/// a better performance. A simulated Gaussian blur with specified blur radius will be applied.
 struct BlurImageProcessor: ImageProcessor {
    
    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     let identifier: String
    
    /// Blur radius for the simulated Gaussian blur.
     let blurRadius: CGFloat

    /// Creates a `BlurImageProcessor`
    ///
    /// - parameter blurRadius: Blur radius for the simulated Gaussian blur.
     init(blurRadius: CGFloat) {
        self.blurRadius = blurRadius
        self.identifier = "com.onevcat.CometChatKingfisher.BlurImageProcessor(\(blurRadius))"
    }
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     func process(item: ImageProcessItem, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        switch item {
        case .image(let image):
            let radius = blurRadius * options.scaleFactor
            return image.cf.scaled(to: options.scaleFactor)
                        .cf.blurred(withRadius: radius)
        case .data:
            return (DefaultImageProcessor.default1 |> self).process(item: item, options: options)
        }
    }
}

/// Processor for adding an overlay to images. Only CG-based images are supported in macOS.
 struct OverlayImageProcessor: ImageProcessor {
    
    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     let identifier: String
    
    /// Overlay color will be used to overlay the input image.
     let overlay: CFCrossPlatformColor
    
    /// Fraction will be used when overlay the color to image.
     let fraction: CGFloat
    
    /// Creates an `OverlayImageProcessor`
    ///
    /// - parameter overlay:  Overlay color will be used to overlay the input image.
    /// - parameter fraction: Fraction will be used when overlay the color to image. 
    ///                       From 0.0 to 1.0. 0.0 means solid color, 1.0 means transparent overlay.
     init(overlay: CFCrossPlatformColor, fraction: CGFloat = 0.5) {
        self.overlay = overlay
        self.fraction = fraction
        self.identifier = "com.onevcat.CometChatKingfisher.OverlayImageProcessor(\(overlay.hex)_\(fraction))"
    }
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     func process(item: ImageProcessItem, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image.cf.scaled(to: options.scaleFactor)
                        .cf.overlaying(with: overlay, fraction: fraction)
        case .data:
            return (DefaultImageProcessor.default1 |> self).process(item: item, options: options)
        }
    }
}

/// Processor for tint images with color. Only CG-based images are supported.
 struct TintImageProcessor: ImageProcessor {
    
    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     let identifier: String
    
    /// Tint color will be used to tint the input image.
     let tint: CFCrossPlatformColor
    
    /// Creates a `TintImageProcessor`
    ///
    /// - parameter tint: Tint color will be used to tint the input image.
     init(tint: CFCrossPlatformColor) {
        self.tint = tint
        self.identifier = "com.onevcat.CometChatKingfisher.TintImageProcessor(\(tint.hex))"
    }
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     func process(item: ImageProcessItem, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image.cf.scaled(to: options.scaleFactor)
                        .cf.tinted(with: tint)
        case .data:
            return (DefaultImageProcessor.default1 |> self).process(item: item, options: options)
        }
    }
}

/// Processor for applying some color control to images. Only CG-based images are supported.
/// watchOS is not supported.
 struct ColorControlsProcessor: ImageProcessor {
    
    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     let identifier: String
    
    /// Brightness changing to image.
     let brightness: CGFloat
    
    /// Contrast changing to image.
     let contrast: CGFloat
    
    /// Saturation changing to image.
     let saturation: CGFloat
    
    /// InputEV changing to image.
     let inputEV: CGFloat
    
    /// Creates a `ColorControlsProcessor`
    ///
    /// - Parameters:
    ///   - brightness: Brightness changing to image.
    ///   - contrast: Contrast changing to image.
    ///   - saturation: Saturation changing to image.
    ///   - inputEV: InputEV changing to image.
     init(brightness: CGFloat, contrast: CGFloat, saturation: CGFloat, inputEV: CGFloat) {
        self.brightness = brightness
        self.contrast = contrast
        self.saturation = saturation
        self.inputEV = inputEV
        self.identifier = "com.onevcat.CometChatKingfisher.ColorControlsProcessor(\(brightness)_\(contrast)_\(saturation)_\(inputEV))"
    }
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     func process(item: ImageProcessItem, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image.cf.scaled(to: options.scaleFactor)
                        .cf.adjusted(brightness: brightness, contrast: contrast, saturation: saturation, inputEV: inputEV)
        case .data:
            return (DefaultImageProcessor.default1 |> self).process(item: item, options: options)
        }
    }
}

/// Processor for applying black and white effect to images. Only CG-based images are supported.
/// watchOS is not supported.
 struct BlackWhiteProcessor: ImageProcessor {
    
    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     let identifier = "com.onevcat.CometChatKingfisher.BlackWhiteProcessor"
    
    /// Creates a `BlackWhiteProcessor`
     init() {}
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     func process(item: ImageProcessItem, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        return ColorControlsProcessor(brightness: 0.0, contrast: 1.0, saturation: 0.0, inputEV: 0.7)
            .process(item: item, options: options)
    }
}

/// Processor for cropping an image. Only CG-based images are supported.
/// watchOS is not supported.
 struct CroppingImageProcessor: ImageProcessor {
    
    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     let identifier: String
    
    /// Target size of output image should be.
     let size: CGSize
    
    /// Anchor point from which the output size should be calculate.
    /// The anchor point is consisted by two values between 0.0 and 1.0.
    /// It indicates a related point in current image. 
    /// See `CroppingImageProcessor.init(size:anchor:)` for more.
     let anchor: CGPoint
    
    /// Creates a `CroppingImageProcessor`.
    ///
    /// - Parameters:
    ///   - size: Target size of output image should be.
    ///   - anchor: The anchor point from which the size should be calculated.
    ///             Default is `CGPoint(x: 0.5, y: 0.5)`, which means the center of input image.
    /// - Note:
    ///   The anchor point is consisted by two values between 0.0 and 1.0.
    ///   It indicates a related point in current image, eg: (0.0, 0.0) for top-left
    ///   corner, (0.5, 0.5) for center and (1.0, 1.0) for bottom-right corner.
    ///   The `size` property of `CroppingImageProcessor` will be used along with
    ///   `anchor` to calculate a target rectangle in the size of image.
    ///    
    ///   The target size will be automatically calculated with a reasonable behavior.
    ///   For example, when you have an image size of `CGSize(width: 100, height: 100)`,
    ///   and a target size of `CGSize(width: 20, height: 20)`: 
    ///   - with a (0.0, 0.0) anchor (top-left), the crop rect will be `{0, 0, 20, 20}`; 
    ///   - with a (0.5, 0.5) anchor (center), it will be `{40, 40, 20, 20}`
    ///   - while with a (1.0, 1.0) anchor (bottom-right), it will be `{80, 80, 20, 20}`
     init(size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        self.size = size
        self.anchor = anchor
        self.identifier = "com.onevcat.CometChatKingfisher.CroppingImageProcessor(\(size)_\(anchor))"
    }
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     func process(item: ImageProcessItem, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image.cf.scaled(to: options.scaleFactor)
                        .cf.crop(to: size, anchorOn: anchor)
        case .data: return (DefaultImageProcessor.default1 |> self).process(item: item, options: options)
        }
    }
}

/// Processor for downsampling an image. Compared to `ResizingImageProcessor`, this processor
/// does not render the images to resize. Instead, it downsample the input data directly to an
/// image. It is a more efficient than `ResizingImageProcessor`.
///
/// Only CG-based images are supported. Animated images (like GIF) is not supported.
 struct DownsamplingImageProcessor: ImageProcessor {
    
    /// Target size of output image should be. It should be smaller than the size of
    /// input image. If it is larger, the result image will be the same size of input
    /// data without downsampling.
     let size: CGSize
    
    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     let identifier: String
    
    /// Creates a `DownsamplingImageProcessor`.
    ///
    /// - Parameter size: The target size of the downsample operation.
     init(size: CGSize) {
        self.size = size
        self.identifier = "com.onevcat.CometChatKingfisher.DownsamplingImageProcessor(\(size))"
    }
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
     func process(item: ImageProcessItem, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        switch item {
        case .image(let image):
            guard let data = image.cf.data(format: .unknown) else {
                return nil
            }
            return CometChatKingfisherWrapper.downsampledImage(data: data, to: size, scale: options.scaleFactor)
        case .data(let data):
            return CometChatKingfisherWrapper.downsampledImage(data: data, to: size, scale: options.scaleFactor)
        }
    }
}

/// Concatenates two `ImageProcessor`s. `ImageProcessor.append(another:)` is used internally.
///
/// - Parameters:
///   - left: The first processor.
///   - right: The second processor.
/// - Returns: The concatenated processor.
@available(*, deprecated,
message: "Will be removed soon. Use `|>` instead.",
renamed: "|>")
 func >>(left: ImageProcessor, right: ImageProcessor) -> ImageProcessor {
    return left.append(another: right)
}

infix operator |>: AdditionPrecedence
 func |>(left: ImageProcessor, right: ImageProcessor) -> ImageProcessor {
    return left.append(another: right)
}

extension CFCrossPlatformColor {
    var hex: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        #if os(macOS)
        (usingColorSpace(.sRGB) ?? self).getRed(&r, green: &g, blue: &b, alpha: &a)
        #else
        getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif

        let rInt = Int(r * 255) << 24
        let gInt = Int(g * 255) << 16
        let bInt = Int(b * 255) << 8
        let aInt = Int(a * 255)
        
        let rgba = rInt | gInt | bInt | aInt
        
        return String(format:"#%08x", rgba)
    }
}
