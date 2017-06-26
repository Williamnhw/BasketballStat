//
//  ShootingView.swift
//  Stat
//
//  Created by William on 13/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit

class ShootingView: UIView {
    
    var viewCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    var raduis: CGFloat {
        return min(bounds.width, bounds.height) / 2
    }
    
    var made = false { didSet {setNeedsDisplay()} }
    
    internal func setUp() {
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        if (made) {
            drawCircle()
        } else {
            drawCross()
        }
    }
    
    
    internal func drawCircle() {
        let circlePath = UIBezierPath(arcCenter: viewCenter, radius: raduis, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.clear.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.red.cgColor
        //you can change the line width
        shapeLayer.lineWidth = 2.0
        
        layer.addSublayer(shapeLayer)
    }
    
    internal func drawCross() {
        let path1 = UIBezierPath()
        path1.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
        path1.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        
        let path2 = UIBezierPath()
        path1.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path1.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        
        let paths = CGMutablePath()
        paths.addPath(path1.cgPath)
        paths.addPath(path2.cgPath)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = paths
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 2.0
        
        layer.addSublayer(shapeLayer)
    }

}


