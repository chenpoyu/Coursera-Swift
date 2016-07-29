//
//  ImageFilterProcessor.swift
//  Filterer
//
//  Created by poyuchen on 2016/5/26.
//  Copyright © 2016年 UofT. All rights reserved.
//

import UIKit

func matrixSum(matrix: [[Int]]) -> Int {
    var sum: Int = 0
    for y in 0..<matrix.count {
        for x in 0..<matrix[0].count {
            sum += matrix[y][x]
        }
    }
    return sum
}

public typealias FilterFunc = (Float) -> UIImage

public class ImageFilterProcessor {
    var image: UIImage
    
    var processFilters = [String: FilterFunc]()
    
    func addProcess(filterName: String, filter: FilterFunc) {
        processFilters[filterName] = filter
    }
    
    public init(image: UIImage) {
        self.image = image
        
        addProcess("Blurry", filter: ( blurry ))
        addProcess("MotionBlurry", filter: ( motionBlurry ))
        addProcess("Contrast", filter: ( contrast ))
        addProcess("Grayscale", filter: ( grayscale ))
        addProcess("HMirror", filter: ( hmirror ))
        addProcess("VMirror", filter: ( vmirror ))
    }
    
    public func doFilter(name: String, factor: Float = 1.0) -> UIImage? {
        if (processFilters[name] != nil) {
            let filterFunc = processFilters[name]!
            return filterFunc(factor)
        }
        
        return nil
    }
    
    public func doFilterList(filters: [(name: String, factor: Float)]) -> UIImage? {
        let originalImage = self.image
        
        for filter in filters {
            self.image = doFilter(filter.name, factor: filter.factor)!
        }
        
        let filteredImage = self.image
        self.image = originalImage
        
        return filteredImage
    }
    
    func blurry(factor: Float)  -> UIImage {
        let filter_small = [
            [0, 1, 0],
            [1, 1, 1],
            [0, 1, 0]
        ]
        let filter_medium = [
            [0, 0, 1, 0, 0],
            [0, 1, 1, 1, 0],
            [1, 1, 1, 1, 1],
            [0, 1, 1, 1, 0],
            [0, 0, 1, 0, 0],
        ]
        let filter_max = [
            [0, 0, 0, 1, 0, 0, 0],
            [0, 0, 1, 1, 1, 0, 0],
            [0, 1, 1, 1, 1, 1, 0],
            [1, 1, 1, 1, 1, 1, 1],
            [0, 1, 1, 1, 1, 1, 0],
            [0, 0, 1, 1, 1, 0, 0],
            [0, 0, 0, 1, 0, 0, 0],
        ]
        
        let matricies = [filter_small, filter_medium, filter_max]
        let matrix = matricies[min(matricies.count-1, Int(round(factor)))]
        let filter = BlurryFilter(image: image, factor: 1.0 / Float(matrixSum(matrix)), matrix: matrix)
        return filter.apply()
    }
    
    func motionBlurry(factor: Float) -> UIImage {
        let filter_small = [
            [1, 0, 0, 0, 0],
            [0, 1, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 1, 0],
            [0, 0, 0, 0, 1]
        ]
        let filter_medium = [
            [1, 0, 0, 0, 0, 0, 0],
            [0, 1, 0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0, 0, 0],
            [0, 0, 0, 1, 0, 0, 0],
            [0, 0, 0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0, 1, 0],
            [0, 0, 0, 0, 0, 0, 1]
        ]
        let filter_max = [
            [1, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 1, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 1, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 1, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 1, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 1, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 1]
        ]
        
        let matricies = [filter_small, filter_medium, filter_max]
        let matrix = matricies[min(matricies.count-1, Int(round(factor)))]
        let filter = BlurryFilter(image: image, factor: 1.0 / Float(matrixSum(matrix)), matrix: matrix)
        return filter.apply()
    }
    
    func contrast(factor: Float) -> UIImage {
        let filter = ContrastFilter(image: image, factor: factor)
        return filter.apply()
    }
    
    func grayscale(factor: Float) -> UIImage {
        let filter = GrayscaleFilter(image: image, factor: factor)
        return filter.apply()
    }
    
    func hmirror(factor: Float) -> UIImage {
        let filter = HMirror(image: image)
        return filter.apply()
    }
    
    func vmirror(factor: Float) -> UIImage {
        let filter = VMirror(image: image)
        return filter.apply()
    }
}
