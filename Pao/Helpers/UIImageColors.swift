//
//  UIImageColors.swift
//  https://github.com/jathu/UIImageColors
//
//  Created by Jathu Satkunarajah (@jathu) on 2015-06-11 - Toronto
//

import UIKit

public struct UIImageColors {
    public var background: UIColor!
    public var primary: UIColor!
    public var secondary: UIColor!
    public var detail: UIColor!
}

public enum UIImageColorsQuality: CGFloat {
    case lowest = 50 // 50px
    case low = 100 // 100px
    case high = 250 // 250px
    case highest = 0 // No scale
}

fileprivate struct UIImageColorsCounter {
    let color: Double
    let count: Int
    init(color: Double, count: Int) {
        self.color = color
        self.count = count
    }
}

/*
 Extension on double that replicates UIColor methods. We DO NOT want these
 exposed outside of the library because they don't make sense outside of the
 context of UIImageColors.
 */
fileprivate extension Double {
    
    private var r: Double {
        let floorMod = floor(self / 1000000)
        return fmod(floorMod, 1000000)
    }
    
    private var g: Double {
        let floorMod = floor(self / 1000)
        return fmod(floorMod, 1000)
    }
    
    private var b: Double {
        return fmod(self, 1000)
    }
    
    var isDarkColor: Bool {
        let red = r * 0.2126
        let green = g * 0.7152
        let blue = b * 0.0722
        let color = red + green + blue
        return color < 127.5
    }
    
    var isBlackOrWhite: Bool {
        return (r > 232 && g > 232 && b > 232) || (r < 23 && g < 23 && b < 23)
    }
    
    func isDistinct(_ other: Double) -> Bool {
        let _r = r
        let _g = g
        let _b = b
        let o_r = other.r
        let o_g = other.g
        let o_b = other.b
        
        let redOne = fabs(_r - o_r) > 63.75
        let greenOne = fabs(_g - o_g) > 63.75
        let blueOne = fabs(_b - o_b) > 63.75
        let one = redOne || greenOne || blueOne
        
        let redGreenTwo = fabs(_r - _g) < 7.65
        let redBlueTwo = fabs(_r - _b) < 7.65
        let redGreenOtherTwo = fabs(o_r - o_g) < 7.65
        let redBlueOtherTwo = fabs(o_r - o_b) < 7.65
        
        let two = !(redGreenTwo && redBlueTwo && redGreenOtherTwo && redBlueOtherTwo)
        
        return one && two
    }
    
    func with(minSaturation: Double) -> Double {
        // Ref: https://en.wikipedia.org/wiki/HSL_and_HSV
        
        // Convert RGB to HSV
        
        let _r = r / 255
        let _g = g / 255
        let _b = b / 255
        var H, S, V: Double
        let greenBlueMax = fmax(_g, _b)
        let M = fmax(_r, greenBlueMax)
        let greenBlueMin = fmin(_g, _b)
        var C = M - fmin(_r, greenBlueMin)
        
        V = M
        S = V == 0 ? 0 : C / V
        
        if minSaturation <= S {
            return self
        }
        
        if C == 0 {
            H = 0
        } else if _r == M {
            let greenBlueDiff = (_g - _b) / C
            H = fmod(greenBlueDiff, 6)
        } else if _g == M {
            H = 2 + (_b - _r) / C
        } else {
            H = 4 + (_r - _g) / C
        }
        
        if H < 0 {
            H += 6
        }
        
        // Back to RGB
        
        C = V * minSaturation
        let diff = fmod(H, 2) - 1
        let X = C * (1 - fabs(diff))
        var R, G, B: Double
        
        switch H {
        case 0...1:
            R = C
            G = X
            B = 0
        case 1...2:
            R = X
            G = C
            B = 0
        case 2...3:
            R = 0
            G = C
            B = X
        case 3...4:
            R = 0
            G = X
            B = C
        case 4...5:
            R = X
            G = 0
            B = C
        case 5..<6:
            R = C
            G = 0
            B = X
        default:
            R = 0
            G = 0
            B = 0
        }
        
        let m = V - C
        let redM = (R + m) * 255
        let red = floor(redM) * 1000000
        let green = floor((G + m) * 255) * 1000
        let blue = floor((B + m) * 255)
        
        return red + green + blue
    }
    
    func isContrasting(_ color: Double) -> Bool {
        let bgLum = (0.2126 * r) + (0.7152 * g) + (0.0722 * b) + 12.75
        let fgLum = (0.2126 * color.r) + (0.7152 * color.g) + (0.0722 * color.b) + 12.75
        if bgLum > fgLum {
            return 1.6 < bgLum / fgLum
        } else {
            return 1.6 < fgLum / bgLum
        }
    }
    
    var uicolor: UIColor {
        let red = CGFloat(r) / 255
        let green = CGFloat(g) / 255
        let blue = CGFloat(b) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    var pretty: String {
        return "\(Int(r)), \(Int(g)), \(Int(b))"
    }
}

extension UIImage {
    private func resizeForUIImageColors(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("UIImageColors.resizeForUIImageColors failed: UIGraphicsGetImageFromCurrentImageContext returned nil.")
        }
        
        return result
    }
    
    
    public func getColors(quality: UIImageColorsQuality = .high, _ completion: @escaping (UIImageColors) -> Void) {
        DispatchQueue.global().async {
            let result = self.getColors(quality: quality)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    
    public func getColors(quality: UIImageColorsQuality = .high) -> UIImageColors {
        var scaleDownSize: CGSize = size
        
        if quality != .highest {
            if size.width < size.height {
                let ratio = size.height / size.width
                let width = quality.rawValue / ratio
                let height = quality.rawValue
                scaleDownSize = CGSize(width: width, height: height)
            } else {
                let ratio = size.width / size.height
                let width = quality.rawValue
                let height = quality.rawValue / ratio
                scaleDownSize = CGSize(width: width, height: height)
            }
        }
        
        let cgImage = resizeForUIImageColors(newSize: scaleDownSize).cgImage!
        let width: Int = cgImage.width
        let height: Int = cgImage.height
        
        let threshold = Int(CGFloat(height) * 0.01)
        var proposed: [Double] = [-1, -1, -1, -1]
        
        guard let data = CFDataGetBytePtr(cgImage.dataProvider!.data) else {
            fatalError("UIImageColors.getColors failed: could not get cgImage data.")
        }
        
        let imageColors = NSCountedSet(capacity: width * height)
        for x in 0..<width {
            for y in 0..<height {
                let pixel: Int = ((width * y) + x) * 4
                if 127 <= data[pixel + 3] {
                    let red = Double(data[pixel + 2]) * 1000000
                    let green = Double(data[pixel + 1]) * 1000
                    let blue = Double(data[pixel])
                    imageColors.add(red + green + blue)
                }
            }
        }
        
        let sortedColorComparator: Comparator = { (main, other) -> ComparisonResult in
            let m = main as! UIImageColorsCounter, o = other as! UIImageColorsCounter
            if m.count < o.count {
                return .orderedDescending
            } else if m.count == o.count {
                return .orderedSame
            } else {
                return .orderedAscending
            }
        }
        
        var enumerator = imageColors.objectEnumerator()
        var sortedColors = NSMutableArray(capacity: imageColors.count)
        while let K = enumerator.nextObject() as? Double {
            let C = imageColors.count(for: K)
            if threshold < C {
                sortedColors.add(UIImageColorsCounter(color: K, count: C))
            }
        }
        sortedColors.sort(comparator: sortedColorComparator)
        
        var proposedEdgeColor: UIImageColorsCounter
        if 0 < sortedColors.count {
            proposedEdgeColor = sortedColors.object(at: 0) as! UIImageColorsCounter
        } else {
            proposedEdgeColor = UIImageColorsCounter(color: 0, count: 1)
        }
        
        if proposedEdgeColor.color.isBlackOrWhite, 0 < sortedColors.count {
            for i in 1..<sortedColors.count {
                let nextProposedEdgeColor = sortedColors.object(at: i) as! UIImageColorsCounter
                let differenceEdgeColor = Double(nextProposedEdgeColor.count) / Double(proposedEdgeColor.count)
                if differenceEdgeColor > 0.3 {
                    if !nextProposedEdgeColor.color.isBlackOrWhite {
                        proposedEdgeColor = nextProposedEdgeColor
                        break
                    }
                } else {
                    break
                }
            }
        }
        proposed[0] = proposedEdgeColor.color
        
        enumerator = imageColors.objectEnumerator()
        sortedColors.removeAllObjects()
        sortedColors = NSMutableArray(capacity: imageColors.count)
        let findDarkTextColor = !proposed[0].isDarkColor
        
        while var K = enumerator.nextObject() as? Double {
            K = K.with(minSaturation: 0.15)
            if K.isDarkColor == findDarkTextColor {
                let C = imageColors.count(for: K)
                sortedColors.add(UIImageColorsCounter(color: K, count: C))
            }
        }
        sortedColors.sort(comparator: sortedColorComparator)
        
        for color in sortedColors {
            let color = (color as! UIImageColorsCounter).color
            
            if proposed[1] == -1 {
                if color.isContrasting(proposed[0]) {
                    proposed[1] = color
                }
            } else if proposed[2] == -1 {
                if !color.isContrasting(proposed[0]) || !proposed[1].isDistinct(color) {
                    continue
                }
                proposed[2] = color
            } else if proposed[3] == -1 {
                if !color.isContrasting(proposed[0]) || !proposed[2].isDistinct(color) || !proposed[1].isDistinct(color) {
                    continue
                }
                proposed[3] = color
                break
            }
        }
        
        let isDarkBackground = proposed[0].isDarkColor
        for i in 1...3 {
            if proposed[i] == -1 {
                proposed[i] = isDarkBackground ? 255255255 : 0
            }
        }
        
        return UIImageColors(
            background: proposed[0].uicolor,
            primary: proposed[1].uicolor,
            secondary: proposed[2].uicolor,
            detail: proposed[3].uicolor
        )
    }
}
