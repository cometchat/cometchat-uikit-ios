



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


#if !os(watchOS)

import CoreImage

// Reuse the same CI Context for all CI drawing.
private let ciContext = CIContext(options: nil)

/// Represents the type of transformer method, which will be used in to provide a `Filter`.
 typealias Transformer = (CIImage) -> CIImage?

/// Represents a processor based on a `CIImage` `Filter`.
/// It requires a filter to create an `ImageProcessor`.
 protocol CIImageProcessor: ImageProcessor {
    var filter: Filter { get }
}

extension CIImageProcessor {
    
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
            return image.cf.apply(filter)
        case .data:
            return (DefaultImageProcessor.default1 |> self).process(item: item, options: options)
        }
    }
}

/// A wrapper struct for a `Transformer` of CIImage filters. A `Filter`
/// value could be used to create a `CIImage` processor.
 struct Filter {
    
    let transform: Transformer

     init(transform: @escaping Transformer) {
        self.transform = transform
    }
    
    /// Tint filter which will apply a tint color to images.
     static var tint: (CFCrossPlatformColor) -> Filter = {
        color in
        Filter {
            input in
            
            let colorFilter = CIFilter(name: "CIConstantColorGenerator")!
            colorFilter.setValue(CIColor(color: color), forKey: kCIInputColorKey)
            
            let filter = CIFilter(name: "CISourceOverCompositing")!
            
            let colorImage = colorFilter.outputImage
            filter.setValue(colorImage, forKey: kCIInputImageKey)
            filter.setValue(input, forKey: kCIInputBackgroundImageKey)
            
            return filter.outputImage?.cropped(to: input.extent)
        }
    }
    
    /// Represents color control elements. It is a tuple of
    /// `(brightness, contrast, saturation, inputEV)`
     typealias ColorElement = (CGFloat, CGFloat, CGFloat, CGFloat)
    
    /// Color control filter which will apply color control change to images.
     static var colorControl: (ColorElement) -> Filter = { arg -> Filter in
        let (brightness, contrast, saturation, inputEV) = arg
        return Filter { input in
            let paramsColor = [kCIInputBrightnessKey: brightness,
                               kCIInputContrastKey: contrast,
                               kCIInputSaturationKey: saturation]
            let blackAndWhite = input.applyingFilter("CIColorControls", parameters: paramsColor)
            let paramsExposure = [kCIInputEVKey: inputEV]
            return blackAndWhite.applyingFilter("CIExposureAdjust", parameters: paramsExposure)
        }
    }
}

extension CometChatKingfisherWrapper where Base: CFCrossPlatformImage {

    /// Applies a `Filter` containing `CIImage` transformer to `self`.
    ///
    /// - Parameter filter: The filter used to transform `self`.
    /// - Returns: A transformed image by input `Filter`.
    ///
    /// - Note:
    ///    Only CG-based images are supported. If any error happens
    ///    during transforming, `self` will be returned.
     func apply(_ filter: Filter) -> CFCrossPlatformImage {
        
        guard let cgImage = cgImage else {
            assertionFailure("[CometChatKingfisher] Tint image only works for CG-based image.")
            return base
        }
        
        let inputImage = CIImage(cgImage: cgImage)
        guard let outputImage = filter.transform(inputImage) else {
            return base
        }

        guard let result = ciContext.createCGImage(outputImage, from: outputImage.extent) else {
            assertionFailure("[CometChatKingfisher] Can not make an tint image within context.")
            return base
        }
        
        #if os(macOS)
            return fixedForRetinaPixel(cgImage: result, to: size)
        #else
            return CFCrossPlatformImage(cgImage: result, scale: base.scale, orientation: base.imageOrientation)
        #endif
    }

}

#endif
