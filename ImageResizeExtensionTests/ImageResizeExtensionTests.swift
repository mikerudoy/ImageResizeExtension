//
//  ImageResizeTests.swift
//  ImageResizeTests
//
//  Created by Mike Rudoy on 9/26/16.
//  Copyright © 2016 Mike Rudoy. All rights reserved.
//

import XCTest
@testable import ImageResizeExtension

class UIImageExtensionTests: XCTestCase {

    func testLargeImageResize() {
        let largeImage = loadLargeImage()
        let resultImage = largeImage.resizeToLessOrEqualDiskSpace(1_000_000)
        let pngData = UIImagePNGRepresentation(resultImage)!
        XCTAssertLessThanOrEqual(pngData.length, 1_000_000)
    }

    func testSmallImageResize() {
        let smallImage = loadSmallImage()
        let resultImage = smallImage.resizeToLessOrEqualDiskSpace(1_000_000)
        let pngData = UIImagePNGRepresentation(resultImage)!
        XCTAssertLessThanOrEqual(pngData.length, 1_000_000)
    }

    func testResizeToSmaller() {
        let largeImage = loadLargeImage()
        let result = try! largeImage.resizeTo(CGSizeMake(400, 500))
        XCTAssertEqual(result.size, CGSizeMake(400, 500))
    }

    func testResizeToLarge() {
        let smallImage = loadSmallImage()
        let result = try! smallImage.resizeTo(CGSizeMake(1000, 1000))
        XCTAssertEqual(result.size, CGSizeMake(1000, 1000))
    }

    func testResizeVerticalImage() {
        let verticalImage = loadVerticalLargeImage()
        let result = try! verticalImage.resizeTo(CGSizeMake(300, 300))
        XCTAssertEqual(result.size, CGSizeMake(300, 300))
    }

    func testResizeToLargeSide() {
        let image = loadSizedImage()
        let result = try! image.resizeToLargeSideEqual(324.0)
        XCTAssertEqual(result.size, CGSizeMake(324.0, 242.0))
    }

    func testResizeToAlpha() {
        let image = loadAlphaImage()
        let result = try! image.resizeTo(CGSizeMake(300, 300))
        XCTAssertEqual(result.size, CGSizeMake(300, 300))
    }

    func testResizeToLargeSideAlphaImages () {
        let image = loadAlphaImage()
        let result = try! image.resizeToLargeSideEqual(232.0)
        XCTAssertEqual(result.size.width, 232.0)
    }

    func loadAlphaImage() -> UIImage {
        return takeResourceImageWithName("alphaImage.png")
    }

    func loadSizedImage() -> UIImage {
        return takeResourceImageWithName("image_2592_1936.jpg")
    }

    func loadLargeImage() -> UIImage {
        return takeResourceImageWithName("horizontal_2.6m.jpg")
    }

    func loadSmallImage() -> UIImage {
        return takeResourceImageWithName("horizontal_0.4m.jpg")
    }

    func loadVerticalLargeImage() -> UIImage {
        return takeResourceImageWithName("vertical_1.7m.jpg")
    }

    func takeResourceImageWithName(name: String) -> UIImage {
        let bundle = NSBundle.init(identifier: "io.github.mikerudoy.ImageResizeExtensionTests")!
        let imagePath = bundle.pathForResource(name, ofType: nil, inDirectory: nil)!
        return UIImage(contentsOfFile: imagePath)!
    }

    func loadImageWithURLString(path: String) -> UIImage {
        let imageURL = NSURL(string: path)!
        let imageData = NSData(contentsOfURL: imageURL)!
        return UIImage(data: imageData)!
    }
    
}
