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
    
    
    func filtered(idCalculate: Int, image: UIImage)-> UIImage {
        let rgbaImage = RGBAImage(image: image)!
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                
                if (ViewController.numOfCalculate != idCalculate) {
//                    print("early returned \(idCalculate)")
                    return image
                }
                
                let index = rgbaImage.width * y + x
                var currentPixel = rgbaImage.pixels.buffer[index]
                
                currentPixel.red = UInt8(Float32(currentPixel.red) * redCoeff > 255 ? Float(255.0) : (Float32(currentPixel.red) * redCoeff))
                currentPixel.green = UInt8((Float32(currentPixel.green) * greenCoeff) > 255 ? 255 : (Float32(currentPixel.green) * greenCoeff))
                currentPixel.blue = UInt8((Float32(currentPixel.blue) * blueCoeff) > 255 ? 255 : (Float32(currentPixel.blue) * blueCoeff))
                
                rgbaImage.pixels.buffer[index] = currentPixel
            }
        }
//        print("returned \(idCalculate)")

        return rgbaImage.toUIImage()!
    }
    
}

class RotateColorFilter: Filter {
    var addIndex: Int
    var coefs: [Float32] = [1.0, 1.0, 1.0]
    init(nextColor: Float32 = 0.5) {
        var deltaColor = nextColor
        if (nextColor < 1.0 / 3.0) {
            self.addIndex = 0
        }
        else if (nextColor > 2.0 / 3.0) {
            deltaColor -= 2.0 / 3.0
            self.addIndex = -1
        }
        else {
            deltaColor -= 1.0 / 3.0
            addIndex = 1
        }
        self.coefs[Int(nextColor*10) % 3] -= deltaColor
        
        super.init()
    }
    
    override
    func filtered(idCalculate: Int, image: UIImage)-> UIImage {
        let rgbaImage = RGBAImage(image: image)!
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                if (ViewController.numOfCalculate != idCalculate) {
//                    print("early returned \(idCalculate)")
                    return image
                }
                let index = rgbaImage.width * y + x
                var currentPixel = rgbaImage.pixels.buffer[index]

                if (addIndex == 1) {
                    let blue = currentPixel.blue
                    currentPixel.blue = UInt8(Float32(currentPixel.green) * coefs[2])
                    currentPixel.green = UInt8(Float32(currentPixel.red) * coefs[1])
                    currentPixel.red = UInt8(Float32(blue) * coefs[0])
                } else if (addIndex == -1) {
                    let green = currentPixel.green
                    currentPixel.green = UInt8(Float32(currentPixel.blue) * coefs[1])
                    currentPixel.blue = UInt8(Float32(currentPixel.red) * coefs[2])
                    currentPixel.red = UInt8(Float32(green) * coefs[0])
                } else {
                    let blue = UInt8(Float32(currentPixel.blue) * coefs[2])
                    currentPixel.blue = UInt8(Float32(currentPixel.red) * coefs[0])
                    currentPixel.red = UInt8(Float32(blue) * coefs[1])
                }
                
                rgbaImage.pixels.buffer[index] = currentPixel
            }
        }
        
//        print("returned \(idCalculate)")
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
    func filtered(idCalculate: Int, image: UIImage)-> UIImage {
        let rgbaImage = RGBAImage(image: image)!
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                if (ViewController.numOfCalculate != idCalculate) {
//                    print("early returned \(idCalculate)")
                    return image
                }
                let index = rgbaImage.width * y + x
                var currentPixel = rgbaImage.pixels.buffer[index]
                
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
                
                rgbaImage.pixels.buffer[index] = currentPixel
            }
        }
//        print("returned \(idCalculate)")

        return rgbaImage.toUIImage()!
    }
}


class CrazyFilter {
    let sourceImg: UIImage
    var filters: [String: Filter]
    init(image: UIImage, dictFilters: [String: Filter]){
        sourceImg = image
        filters = dictFilters
    }
    
    func changeFilter(nameOfFilter: String, newFilter: Filter)-> Void {
        if let _ = filters[nameOfFilter] {
            filters[nameOfFilter] = newFilter
        }
    }
    
    
    // You can to apply list of the filters
    func applyFilters(idCalculate: Int, namesOfFilters: [String])-> UIImage {
        var destinationImg = sourceImg
        for name in namesOfFilters {
            if let filter = filters[name] {
                destinationImg = filter.filtered(idCalculate,image: destinationImg)
            }
        }
        return destinationImg
    }
    
    //you can apply one of the filters
    func applyFilter(idCalculate: Int, nameOfFilter: String)-> UIImage {
       var  destinationImg = sourceImg
        if let filter = filters[nameOfFilter] {
            destinationImg = filter.filtered(idCalculate, image: destinationImg)
        }
        return destinationImg
    }
    
}