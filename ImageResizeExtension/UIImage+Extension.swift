 //
//  UIImage+Extension.swift
//
//  Created by Mike Rudoy on 9/5/16.
//  Copyright © 2016 Mike Rudoy. All rights reserved.
//

import UIKit

/**
 The `UIImage` extension.
 */
extension UIImage {

    /// Start value for transform scale ratio.
    @nonobjc static let kResizeMultiplierInitialValue = 1.1

    /// Step for increasing resizing ratio after image not confirm disc space size condition.
    @nonobjc static let kResizeMultiplierStep = 2.0

    /// Quality for interpolation while resizing image.
    @nonobjc static let kResizeIntropolationQuality: CGInterpolationQuality = .Medium

    /// Strategy used in project.
    static let kResizeTypeStrategy: ImageResizeType = ImageResizeType.Fill

    /**
     Resize image to confirm disk size condition.
     */
    public func resizeToLessOrEqualDiskSpace(size: Int) -> UIImage {
        var scaledImage = self
        var pngData = convertToPNGData(self)
        var resizeMultiplier = UIImage.kResizeMultiplierInitialValue
        while (pngData.length > size) {
            let ratio = calculateTransformRatio(pngData.length,
                                                neededDiskSize: size,
                                                multiplier:resizeMultiplier)
            let size = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(ratio, ratio))
            let hasAlpha = false
            let scale: CGFloat = 0.0

            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
            self.drawInRect(CGRect(origin: CGPointZero, size: size))
            scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            pngData = convertToPNGData(scaledImage)
            resizeMultiplier += UIImage.kResizeMultiplierStep
        }
        return scaledImage
    }

    /**
     Returns image from current image context, satisfying size parameter condition.

     - parameter size: resulting size for image.

     - returns: Scaled Image.
     */
    private func makeScaledImage(size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        self.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return scaledImage
    }

    /**
     Calculate transform ratio with input parameters.

     - parameter existingDiskSize: current image size on disk.
     - parameter neededDiskSize:   needed image size on disk.
     - parameter multiplier:       multiplier for reduce while cycle count.

     - returns: transform ratio.
     */
    private func calculateTransformRatio(existingDiskSize: Int, neededDiskSize: Int, multiplier:Double) -> CGFloat {
        let pureRatio = Double(existingDiskSize) / Double(neededDiskSize)
        let sizeRatio = sqrt(pureRatio)
        let ratioWithMultiplier = sizeRatio * multiplier
        return CGFloat(1 / ratioWithMultiplier)
    }

    /**
     Returns unwrapped PNG image data

     - parameter image: Image to represent with PNG data.

     - returns: png data.
     */
    private func convertToPNGData(image:UIImage) -> NSData {
        let pngData = UIImagePNGRepresentation(image)
        return pngData!
    }

    /**
     Resize image to new size, by fitting in result size.

     - parameter newSize: needed size.

     - throws: BitmapContextCreateFail.

     - returns: new image that fitting in needed size.
     */
    public func resizeTo(newSize: CGSize) throws -> UIImage {

        let imageSizeCalculator = ImageSizeCalculator(neededSize: newSize,
                                                      initialSize: size,
                                                      resizeStrategy: ImageResizeType.Fit)

        let imageRect = imageSizeCalculator.getImageRect()
        let canvasSize = imageSizeCalculator.getCanvasSize()
        let transposedRect:CGRect = CGRectMake(0, 0, imageRect.size.height, imageRect.size.width)

        let transform = transformForOrientation(canvasSize)
        let shouldTranspose =  self.imageOrientation == .Left
                            || self.imageOrientation == .Right
                            || self.imageOrientation == .LeftMirrored
                            || self.imageOrientation == .RightMirrored

        let imageRef = self.CGImage!;
        let bitmap = CGBitmapContextCreate(nil,
                                           Int(canvasSize.width),
                                           Int(canvasSize.height),
                                           CGImageGetBitsPerComponent(imageRef),
                                           0,
                                           CGImageGetColorSpace(imageRef)!,
                                           CGImageGetBitmapInfo(imageRef).rawValue)!

        CGContextConcatCTM(bitmap, transform)
        CGContextSetInterpolationQuality(bitmap, UIImage.kResizeIntropolationQuality)

        CGContextDrawImage(bitmap, shouldTranspose ? transposedRect : imageRect, imageRef);

        guard let newImageRef = CGBitmapContextCreateImage(bitmap) else {
            throw ResizeException.BitmapContextCreateFail
        }
        let resultImage = UIImage(CGImage: newImageRef)
        return resultImage
    }

    func transformForOrientation(newSize:CGSize) -> CGAffineTransform {
        var transform:CGAffineTransform = CGAffineTransformIdentity
        switch (self.imageOrientation) {
        case .UpMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .Down:
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        case .DownMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            transform = CGAffineTransformTranslate(transform, newSize.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .Left:
            transform = CGAffineTransformTranslate(transform, newSize.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        case .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            transform = CGAffineTransformTranslate(transform, newSize.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .Right:
            transform = CGAffineTransformTranslate(transform, 0, newSize.height)
            transform = CGAffineTransformRotate(transform, -CGFloat(M_PI_2))
        case .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, newSize.height)
            transform = CGAffineTransformRotate(transform, -CGFloat(M_PI_2))
            transform = CGAffineTransformTranslate(transform, newSize.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        default:
            break
        }
        return transform
    }


    /// Returns UIImage where large side will be equal to largeSide parameter, and image will be scaled to save itself proportions.
    ///
    /// - Parameter largeSide: The new size for larger size of image.
    /// - Returns: The scaled image.
    public func resizeToLargeSideEqual(largeSide: CGFloat) throws -> UIImage {
        let height = self.size.height
        let width = self.size.width
        let sourceLargeSize = max(height, width)
        let scale = largeSide / sourceLargeSize
        do {
            return try resizeTo(CGSize(width: width*scale, height: height*scale))
        } catch ResizeException.BitmapContextCreateFail {
            throw ResizeException.BitmapContextCreateFail
        }
    }
}
