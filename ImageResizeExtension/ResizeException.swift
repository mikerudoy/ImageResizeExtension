//
//  ImageResizeExceptions.swift
//
//  Created by Mike Rudoy on 9/12/16.
//  Copyright © 2016 Mike Rudoy. All rights reserved.
//

import Foundation

/**
 Exceptions that can be throwed by [UIImage Extension](../Extensions/UIImage.html)
 */
enum ResizeException : ErrorType {
    /// Exception raised when could not create UIImage from ImageRef.
    case BitmapContextCreateFail
}