//
//  MultipleImageFilter.swift
//  Filterer
//
//  Created by poyuchen on 2016/5/26.
//  Copyright © 2016年 UofT. All rights reserved.
//

import UIKit

public class GrayscaleFilter: ImageFilter {
    override func modify(var pixel: Pixel, x: Int, y: Int) -> Pixel {
        let r = Float(pixel.red) * 0.2126
        let g = Float(pixel.green) * 0.7152
        let b = Float(pixel.blue) * 0.0722
        let gray = (r + g + b) * factor
        
        pixel.red = transInt(gray)
        pixel.green = transInt(gray)
        pixel.blue = transInt(gray)
        
        return pixel
    }
}

public class BlurryFilter: ImageFilter {
    var filterMatrix: [[Int]] = [    // normal filter - no change
        [0, 0, 0],
        [0, 1, 0],
        [0, 0, 0]
    ]
    var filterHeight: Int { return filterMatrix.count }
    var filterWidth: Int { return filterMatrix[0].count }
    var bias: Int = 0
    
    public init(image: UIImage, factor: Float, matrix: [[Int]], bias: Int = 0) {
        super.init(image: image, factor: factor)
        
        self.filterMatrix = matrix
        self.bias = bias
    }
    
    override func modify(var pixel: Pixel, x: Int, y: Int) -> Pixel {
        var red:Float = 0.0
        var green:Float = 0.0
        var blue:Float = 0.0
        
        for filterY in 0..<filterHeight {
            for filterX in 0..<filterWidth {
                let imageX = (x - filterWidth / 2 + filterX + imageWidth) % imageWidth
                let imageY = (y - filterHeight / 2 + filterY + imageHeight) % imageHeight
                
                let px = pixelAt(imageX, y: imageY)
                
                red += Float(Int(px.red) * filterMatrix[filterY][filterX])
                green += Float(Int(px.green) * filterMatrix[filterY][filterX])
                blue += Float(Int(px.blue) * filterMatrix[filterY][filterX])
            }
        }
        
        pixel.red = transInt(factor * red + Float(bias))
        pixel.green = transInt(factor * green + Float(bias))
        pixel.blue = transInt(factor * blue + Float(bias))
        
        return pixel
    }
}

public class ContrastFilter : ImageFilter{
    var avgRed:Float = 0
    var avgBlue:Float = 0
    var avgGreen:Float = 0
    
    override func modify(pixel: Pixel, x: Int, y: Int) -> Pixel {
        setPixel(x, y: y, pixel: pixel)
        return pixel
    }
    
    override func preModify() {
        var totalRed:Float = 0
        var totalGreen:Float = 0
        var totalBlue:Float = 0
        
        for y in 0..<rgbaImage!.height {
            for x in 0..<rgbaImage!.width {
                let index = y * rgbaImage!.width + x
                let pixel = rgbaImage!.pixels[index]
                totalBlue += Float(pixel.blue)
                totalRed += Float(pixel.red)
                totalGreen += Float(pixel.green)
            }
        }
        
        let totalPixelCount:Float = Float(rgbaImage!.width) * Float(rgbaImage!.height)
        avgRed = totalRed / totalPixelCount
        avgBlue = totalBlue / totalPixelCount
        avgGreen = totalGreen / totalPixelCount
    }
    
    override public func apply () -> UIImage {
        preModify()
        
        for y in 0..<rgbaImage!.height {
            for x in 0..<rgbaImage!.width {
                var targetPixel = pixelAt(x, y: y)
                let deltaRed:Float = Float(targetPixel.red) - avgRed
                let deltaBlue:Float = Float(targetPixel.blue) - avgBlue
                let deltaGreen:Float = Float(targetPixel.green) - avgGreen
                
                targetPixel.red = transInt(avgRed + factor * deltaRed)
                targetPixel.blue = transInt(avgBlue + factor * deltaBlue)
                targetPixel.green = transInt(avgGreen + factor * deltaGreen)
                modify(targetPixel, x: x, y: y)
            }
        }
        
        return (rgbaImage?.toUIImage()!)!
    }
}

public class HMirror: ImageFilter {
    override public func apply () -> UIImage {
        
        var newImage = RGBAImage(image: originalImage!)!
        for y in 0..<imageHeight {
            for x in 0..<imageWidth/2 {
                
                let indexA = y * rgbaImage!.width + x
                let indexB = y * rgbaImage!.width + (rgbaImage!.width - x - 1)
                
                newImage.pixels[indexA] = rgbaImage!.pixels[indexB]
                newImage.pixels[indexB] = rgbaImage!.pixels[indexA]
            }
        }
        
        return newImage.toUIImage()!
    }
}

public class VMirror: ImageFilter {
    override public func apply () -> UIImage {
        
        var newImage = RGBAImage(image: originalImage!)!
        for y in 0..<rgbaImage!.height/2 {
            for x in 0..<rgbaImage!.width {
                
                let indexA = y * rgbaImage!.width + x
                let indexB = (rgbaImage!.height - y - 1) * rgbaImage!.width + x
                
                newImage.pixels[indexA] = rgbaImage!.pixels[indexB]
                newImage.pixels[indexB] = rgbaImage!.pixels[indexA]
            }
        }
        
        return newImage.toUIImage()!
    }
}
