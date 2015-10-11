//
//  CanvasView.swift
//  CanvasViewExample
//
//  Created by Danny Yassine on 2015-10-09.
//  Copyright © 2015 Danny Yassine. All rights reserved.
//

import UIKit

//MARK: BRUSH

class BrushLayer: CAShapeLayer {
    override init() {
        super.init()
        self.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        self.strokeColor = UIColor.blackColor().CGColor
        self.lineWidth = 2.0
        self.fillColor = UIColor.clearColor().CGColor
        self.lineCap = kCALineCapRound
        self.lineJoin = kCALineJoinBevel
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: DRAWING LAYER

class DrawView: UIView {
    
    var drawPath: UIBezierPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.setBezierPath()
        
    }

    func setBezierPath() {
        self.drawPath = UIBezierPath()
        self.drawPath.lineWidth = 5.0
        self.drawPath.lineCapStyle = CGLineCap.Round
        self.drawPath.lineJoinStyle = CGLineJoin.Round
        UIColor.clearColor().setFill()
        UIColor.blackColor().setStroke()
        self.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Drawing
    
    override func drawRect(rect: CGRect) {
        
        self.drawPath.stroke()
    }
}

class CanvasView: UIImageView {

    var previousPoint: CGPoint!
    var previousView: UIImageView!
    var drawingView: DrawView!
    var layers = [CAShapeLayer]()
    var undoLayers = [CAShapeLayer]()
    
    //MARK: Initializers
    
    func commonInit() {
        
        let pan = UIPanGestureRecognizer(target: self, action: "pan:")
        
        // If you want to present the previous drawed image
        self.previousView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.previousView.contentMode = .ScaleAspectFit
        self.addSubview(self.previousView)
        self.previousView.alpha = 0.4
        
        self.drawingView = DrawView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.addSubview(self.drawingView)
        self.addGestureRecognizer(pan)
        
        self.userInteractionEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    //MARK: Gesture
    
    func pan(pan: UIPanGestureRecognizer) {
        
        let location: CGPoint = pan.locationInView(self)
        let velocity: CGPoint = pan.velocityInView(self)
        
        if pan.state == .Began {

        } else if pan.state == .Changed {
            
            if self.previousPoint == nil {
                self.previousPoint = location
                self.drawingView.drawPath.moveToPoint(location)
            }
            
            let middlePoint = self.getMidPoint(self.previousPoint, secondPoint: location)
            self.drawingView.drawPath.addQuadCurveToPoint(middlePoint, controlPoint: self.previousPoint)
            self.previousPoint = location
            
            self.drawingView.setNeedsDisplay()
            
        } else if pan.state == .Ended {
            // add layers
            
            self.extractDrawingToLayer()
            self.previousPoint = nil
            
            self.drawingView.setBezierPath()
            
        }
        
    }
    
    //MARK: MidPoint
    
    func getMidPoint(firstPoint: CGPoint, secondPoint: CGPoint) -> CGPoint {
        return CGPointMake((firstPoint.x + secondPoint.x) / 2, (firstPoint.y + secondPoint.y) / 2)
    }
    
    //MARK: Extract drawed layer on DrawingView and prints it on CanvasView
    
    func extractDrawingToLayer() {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.mainScreen().scale)
        self.drawingView.drawViewHierarchyInRect(self.drawingView.bounds, afterScreenUpdates: false)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let layer = BrushLayer()
        layer.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        layer.contents = newImage.CGImage
        self.layers.append(layer)
        self.layer.addSublayer(layer)
        
    }
    
    //MARK: UNDO & REDO
    
    func undo() {
        
        if self.layers.count == 0 {
            return
        }
        
        let layer = self.layers.removeAtIndex(self.layers.count - 1)
        self.undoLayers.append(layer)
        layer.removeFromSuperlayer()
        
    }
    
    func redo() {
        
        if self.undoLayers.count == 0 {
            return
        }
        
        let layer = self.undoLayers.removeAtIndex(self.undoLayers.count - 1)
        self.layers.append(layer)
        self.layer.addSublayer(layer)
        
    }
    
    //MARK: Extract Drawing
    
    func extractDrawing() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.mainScreen().scale)
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: false)
        let imageOfDrawing = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageOfDrawing
    }
    

}
