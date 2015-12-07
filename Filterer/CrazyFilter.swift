//
//  CrazyFilter.swift
//  Filterer
//
//  Created by lilil on 05.12.15.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class Filter {
    var redCoeff: Float32
    var greenCoeff: Float32
    var blueCoeff: Float32
    
    
    init(redCoeff: Float32 = 1, greenCoeff: Float32 = 1, blueCoeff: Float32 = 1) {
        self.redCoeff = redCoeff
        self.greenCoeff = greenCoeff
        self.blueCoeff = blueCoeff
    }
    
    
    func filtered(image: UIImage)-> UIImage {
        let rgbaImage = RGBAImage(image: image)!
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = rgbaImage.width * y + x
                var currentPixel = rgbaImage.pixels[index]
                
                currentPixel.red = UInt8(Float32(currentPixel.red) * redCoeff > 255 ? Float(255.0) : (Float32(currentPixel.red) * redCoeff))
                currentPixel.green = UInt8((Float32(currentPixel.green) * greenCoeff) > 255 ? 255 : (Float32(currentPixel.green) * greenCoeff))
                currentPixel.blue = UInt8((Float32(currentPixel.blue) * blueCoeff) > 255 ? 255 : (Float32(currentPixel.blue) * blueCoeff))
                
                rgbaImage.pixels[index] = currentPixel
            }
        }
        
        return rgbaImage.toUIImage()!
    }
    
}

class RotateColorFilter: Filter {
    var addIndex: Int
    init(nextColor: Float32 = 0.5) {
        if (nextColor < 1.0 / 3.0) {
            self.addIndex = 0
        }
        else if (nextColor > 2.0 / 3.0) {
            self.addIndex = -1
        }
        else {
            addIndex = 1
        }
        
        super.init()
    }
    
    override
    func filtered(image: UIImage)-> UIImage {
        let rgbaImage = RGBAImage(image: image)!
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = rgbaImage.width * y + x
                var currentPixel = rgbaImage.pixels[index]

                if (addIndex == 1) {
                    let blue = currentPixel.blue
                    currentPixel.blue = currentPixel.green
                    currentPixel.green = currentPixel.red
                    currentPixel.red = blue
                } else if (addIndex == -1) {
                    let green = currentPixel.green
                    currentPixel.green = currentPixel.blue
                    currentPixel.blue = currentPixel.red
                    currentPixel.red = green
                } else {
                    let blue = currentPixel.blue
                    currentPixel.blue = currentPixel.red
                    currentPixel.red = blue
                }
                
                rgbaImage.pixels[index] = currentPixel
            }
        }
        
        return rgbaImage.toUIImage()!
    }
}

class BlackAndWhiteFilter: Filter {
    var coeff: Float32
    init(commonCoeff: Float32 = 0) {
        self.coeff = commonCoeff + 1
        super.init()
    }
    
    override
    func filtered(image: UIImage)-> UIImage {
        let rgbaImage = RGBAImage(image: image)!
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = rgbaImage.width * y + x
                var currentPixel = rgbaImage.pixels[index]
                
                if (UInt16(currentPixel.red) + UInt16(currentPixel.green) + UInt16(currentPixel.blue) > 381) {
                    var color = Float32(currentPixel.red/3 + currentPixel.green/3 + currentPixel.blue/3) * coeff
                    if (color > 255) {
                        color = 255
                    }

                    currentPixel.red = UInt8(color)
                    currentPixel.green = UInt8(color)
                    currentPixel.blue = UInt8(color)
                } else {
                    var color = Float32(currentPixel.red/3 + currentPixel.green/3 + currentPixel.blue/3) / coeff
                    if (color > 255) {
                        color = 255
                    }
                    currentPixel.red = UInt8(color)
                    currentPixel.green = UInt8(color)
                    currentPixel.blue = UInt8(color)
                }
                
                rgbaImage.pixels[index] = currentPixel
            }
        }
        
        return rgbaImage.toUIImage()!
    }
}


class CrazyFilter {
    let sourceImg: UIImage
    var destinationImg: UIImage
    var filters: [String: Filter]
    init(image: UIImage, dictFilters: [String: Filter]){
        sourceImg = image
        destinationImg = sourceImg
        filters = dictFilters
    }
    
    func changeFilter(nameOfFilter: String, newFilter: Filter)-> Void {
        if let _ = filters[nameOfFilter] {
            filters[nameOfFilter] = newFilter
        }
    }
    
    
    // You can to apply list of the filters
    func applyFilters(namesOfFilters: [String])-> UIImage {
        destinationImg = sourceImg
        for name in namesOfFilters {
            if let filter = filters[name] {
                destinationImg = filter.filtered(destinationImg)
            }
        }
        return destinationImg
    }
    
    //you can apply one of the filters
    func applyFilter(nameOfFilter: String)-> UIImage {
        destinationImg = sourceImg
        if let filter = filters[nameOfFilter] {
            destinationImg = filter.filtered(destinationImg)
        }
        return destinationImg
    }
    
}