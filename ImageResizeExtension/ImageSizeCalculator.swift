//
//  ImageSizeCalculator.swift
//
//  Created by Mike Rudoy on 9/12/16.
//  Copyright © 2016 Mike Rudoy. All rights reserved.
//

import UIKit

/// The `ImageSizeCalculator` is helper class for calculating resize rectangles. Uses in [UIImage Extension](../Extensions/UIImage.html)
class ImageSizeCalculator {
    /// Size of image that we need.
    let neededSize: CGSize
    /// Size of image to resize.
    let initialSize: CGSize
    /// Strategy for resizing image with saving original ratio.
    let resizeStrategy: ImageResizeType

    /// Ratio to properly X scale.
    private var widthScaleRatio : CGFloat {
        return neededSize.width / initialSize.width
    }

    /// Ratio to properly Y scale.
    private var heightScaleRatio : CGFloat {
        return neededSize.height / initialSize.height
    }

    /// Ratio that will be performed for scale.
    private var ratio: CGFloat {
        switch resizeStrategy {
        case .Fit:
            return min(widthScaleRatio, heightScaleRatio)
        case .Fill:
            return max(widthScaleRatio, heightScaleRatio)
        }
    }

    /// New image size.
    private var newImageSize: CGSize {
        return CGSize(width: initialSize.width * ratio,
                      height: initialSize.height * ratio)
    }

    /**
     Creates an instance of the calculator with specified parameters.

     - parameter neededSize:     size of output image.
     - parameter initialSize:    size of input image.
     - parameter resizeStrategy: resize strategy.

     - returns: The `ImageSizeCalculator` instance.
     */
    init (neededSize: CGSize, initialSize: CGSize, resizeStrategy: ImageResizeType) {
        self.neededSize = neededSize
        self.initialSize = initialSize
        self.resizeStrategy = resizeStrategy
    }

    /**
     Returns canvas size.

     - returns: Canvas size.
     */
    func getCanvasSize() -> CGSize {
        return neededSize
    }

    /**
     Returns resized image rectangle.

     - returns: Resized image rectangle
     */
    func getImageRect() -> CGRect {
        let imageRectOriginX = calculateOriginX()
        let imageRectOriginY = calculateOriginY()
        let originPoint = CGPoint(x: imageRectOriginX, y: imageRectOriginY)
        return CGRect(origin: originPoint, size: newImageSize)
    }

    /**
     Returns image origin X.

     - returns: image origin X.
     */
    private func calculateOriginX() -> CGFloat {
        var imageRectOriginX: CGFloat = 0
        let shouldHaveOriginMoreThanZero = resizeStrategy == .Fit && widthScaleRatio > ratio
            || resizeStrategy == .Fill && widthScaleRatio < ratio
        if (shouldHaveOriginMoreThanZero) {
            let greaterSide = max(neededSize.width, newImageSize.width)
            let lowerSide = min(neededSize.width, newImageSize.width)
            let diffSideSize = greaterSide - lowerSide
            imageRectOriginX = diffSideSize / 2
        }
        switch resizeStrategy {
        case .Fit:
            return imageRectOriginX
        case .Fill:
            return -imageRectOriginX
        }
    }

    /**
     Returns image origin Y.

     - returns: image origin Y.
     */
    private func calculateOriginY() -> CGFloat {
        var imageRectOriginY: CGFloat = 0
        let shouldHaveOriginMoreThanZero = resizeStrategy == .Fit && heightScaleRatio > ratio
            || resizeStrategy == .Fill && heightScaleRatio < ratio
        if (shouldHaveOriginMoreThanZero) {
            let greaterSide = max(neededSize.height, newImageSize.height)
            let lowerSide = min(neededSize.height, newImageSize.height)
            let diffSideSize = greaterSide - lowerSide
            imageRectOriginY = diffSideSize / 2
        }
        switch resizeStrategy {
        case .Fit:
            return imageRectOriginY
        case .Fill:
            return -imageRectOriginY
        }
    }
}