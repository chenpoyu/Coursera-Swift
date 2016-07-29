import UIKit

public class GrayscaleFilter: ImageFilter {
    override func modify(var pixel: Pixel, x: Int, y: Int) -> Pixel {
        let gray = (Double(pixel.red) * 0.2126 + Double(pixel.green) * 0.7152 + Double(pixel.blue) * 0.0722) * factor
        
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
    
    public init(image: UIImage, factor: Double, matrix: [[Int]], bias: Int = 0) {
        super.init(image: image, factor: factor)
        
        self.filterMatrix = matrix
        self.bias = bias
    }
    
    override func modify(var pixel: Pixel, x: Int, y: Int) -> Pixel {
        var red = 0.0
        var green = 0.0
        var blue = 0.0
        
        for filterY in 0..<filterHeight {
            for filterX in 0..<filterWidth {
                let imageX = (x - filterWidth / 2 + filterX + imageWidth) % imageWidth
                let imageY = (y - filterHeight / 2 + filterY + imageHeight) % imageHeight
                
                let px = pixelAt(imageX, y: imageY)
                
                red += Double(Int(px.red) * filterMatrix[filterY][filterX])
                green += Double(Int(px.green) * filterMatrix[filterY][filterX])
                blue += Double(Int(px.blue) * filterMatrix[filterY][filterX])
            }
        }
        
        pixel.red = transInt(factor * red + Double(bias))
        pixel.green = transInt(factor * green + Double(bias))
        pixel.blue = transInt(factor * blue + Double(bias))
        
        return pixel
    }
}

public class ContrastFilter : ImageFilter{
    var avgRed:Double = 0
    var avgBlue:Double = 0
    var avgGreen:Double = 0
    
    override func modify(pixel: Pixel, x: Int, y: Int) -> Pixel {
        setPixel(x, y: y, pixel: pixel)
        return pixel
    }
    
    override func preModify() {
        var totalRed:Double = 0
        var totalGreen:Double = 0
        var totalBlue:Double = 0
        
        for y in 0..<rgbaImage!.height {
            for x in 0..<rgbaImage!.width {
                let index = y * rgbaImage!.width + x
                let pixel = rgbaImage!.pixels[index]
                totalBlue += Double(pixel.blue)
                totalRed += Double(pixel.red)
                totalGreen += Double(pixel.green)
            }
        }
        
        let totalPixelCount:Double = Double(rgbaImage!.width) * Double(rgbaImage!.height)
        avgRed = totalRed / totalPixelCount
        avgBlue = totalBlue / totalPixelCount
        avgGreen = totalGreen / totalPixelCount
    }
    
    override public func apply () -> UIImage {
        preModify()
        
        for y in 0..<rgbaImage!.height {
            for x in 0..<rgbaImage!.width {
                var targetPixel = pixelAt(x, y: y)
                let deltaRed:Double = Double(targetPixel.red) - avgRed
                let deltaBlue:Double = Double(targetPixel.blue) - avgBlue
                let deltaGreen:Double = Double(targetPixel.green) - avgGreen
                
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
        
        let newImage = RGBAImage(image: originalImage!)!
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
        
        let newImage = RGBAImage(image: originalImage!)!
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