import UIKit

public class ImageFilter {
    
    var originalImage: UIImage?
    var rgbaImage: RGBAImage?
    var factor: Double = 1.0
    
    var imageWidth: Int = 0
    var imageHeight: Int = 0
    var imageSize: Int { return imageHeight * imageWidth }
    
    public init(image: UIImage, factor: Double) {
        self.originalImage = image
        self.factor = factor
        self.rgbaImage = RGBAImage(image: image)!
        self.imageWidth = rgbaImage!.width
        self.imageHeight = rgbaImage!.height
    }
    
    public convenience init(image: UIImage) {
        self.init(image: image, factor: 1.0)
    }
    
    func pixelAt(x: Int, y: Int) -> Pixel {
        let index = y * imageWidth + x
        return rgbaImage!.pixels[index]
    }
    
    func setPixel(x: Int, y: Int, pixel: Pixel) {
        let index = y * imageWidth + x
        rgbaImage!.pixels[index] = pixel
    }
    
    func transInt(val: Double) -> UInt8 {
        return UInt8(max(min(255, val), 0))
    }
    
    func setPixel(x: Int, y: Int, red: Double, green: Double, blue: Double) {
        var pixel = pixelAt(x, y: y)
        
        pixel.red = transInt(red)
        pixel.green = transInt(green)
        pixel.blue = transInt(blue)
        
        setPixel(x, y: y, pixel: pixel)
    }
    
    // Override modify to apply filter for each pixel
    func modify(pixel: Pixel, x: Int = -1, y: Int = -1) -> Pixel {
        return pixel
    }
    
    func preModify() { }
    
    func postModify() { }
    
    public func apply() -> UIImage {
        preModify()
        
        for y in 0..<imageHeight {
            for x in 0..<imageWidth {
                // for each pixel, modify it and replace it
                setPixel(x, y: y, pixel: modify(pixelAt(x, y: y), x: x, y: y))
            }
        }
        
        postModify()
        
        return (rgbaImage?.toUIImage()!)!
    }
}