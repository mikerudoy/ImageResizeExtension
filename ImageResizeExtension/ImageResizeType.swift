//
//  ImageResizeType.swift
//
//  Created by Mike Rudoy on 9/12/16.
//  Copyright © 2016 Mike Rudoy. All rights reserved.
//

import Foundation

/**
 Strategy while resizing image for saving original ratio in [UIImage Extension](../Extensions/UIImage.html)
 */
enum ImageResizeType {
    /// Add empty black areas for saving original ratio.
    case Fit
    /// Crop result image for saving original ratio.
    case Fill
}