//
//  LoopLabelView.swift
//  LEDDemo
//
//  Created by Mac-0006 on 27/07/23.
//

import Foundation
import UIKit

class DottedMarqueeLabel: UIView {
    
    let dotSize: CGFloat = 10
    let dotSpacing: CGFloat = 2
    let characterSpacing: CGFloat = 10
    
    var text: String = "" {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(UIColor.red.cgColor)
        
        let characters = Array(text)
        
        let totalWidth = calculateTotalWidth(for: characters)
        var x: CGFloat = (self.bounds.size.width - totalWidth) / 2
        var y: CGFloat = (self.bounds.size.height - (dotSize + dotSpacing) * CGFloat(DottedMarqueeLabel.characterPatterns[characters.first!]?[0].count ?? 0)) / 2
        
        for character in characters {
            guard let pattern = DottedMarqueeLabel.characterPatterns[character] else { continue }
            
            for row in pattern {
                for isDot in row {
                    if isDot {
                        context.fill(CGRect(x: x, y: y, width: dotSize, height: dotSize))
                    }
                    x += dotSize + dotSpacing
                }
                x -= (dotSize + dotSpacing) * CGFloat(row.count)
                y += dotSize + dotSpacing
            }
            x += (dotSize + dotSpacing) * CGFloat(pattern[0].count) + characterSpacing
            y = (self.bounds.size.height - (dotSize + dotSpacing) * CGFloat(pattern.count)) / 2
        }
    }
    
    func calculateTotalWidth(for characters: [Character]) -> CGFloat {
        var totalWidth: CGFloat = 0
        for character in characters {
            if let pattern = DottedMarqueeLabel.characterPatterns[character] {
                totalWidth += (dotSize + dotSpacing) * CGFloat(pattern[0].count) + characterSpacing
            }
        }
        return totalWidth - characterSpacing  // subtract the last characterSpacing because it's not needed
    }
    
    static let characterPatterns: [Character: [[Bool]]] = [
        "A": [
            [false, true, false],
            [true, false, true],
            [true, true, true],
            [true, false, true],
            [true, false, true]
        ]
        // add more character patterns here...
    ]
}

