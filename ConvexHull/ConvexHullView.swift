//
//  ConvexHullView.swift
//  ConvexHull
//
//  Created by Ariel Rodriguez on 2/5/17.
//  Copyright © 2017 VolonBolon. All rights reserved.
//

import Cocoa
import CoreGraphics

struct IntPoint {
    let x:UInt32
    let y:UInt32
}

struct Limits {
    let lowerLeft:IntPoint
    let upperRight:IntPoint
}

struct ReversePolarSorter {
    let base:IntPoint
}

class ConvexHullView: NSView {
    var datasource:Datasource!
    
    override init(frame:NSRect) {
        super.init(frame: frame)
        self.loadDatasource()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadDatasource()
    }
    
    func loadDatasource() {
        let ll = IntPoint(x: 10, y: 10)
        let boundsSize = self.bounds.size
        let ur = IntPoint(x: UInt32(boundsSize.width)-20, y: UInt32(boundsSize.height)-20)
        let limits = Limits(lowerLeft: ll, upperRight: ur)
        let e:Either<Limits,[CGPoint]> = .Left(limits)
        self.datasource = Datasource(limitsOrPoints:e)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.white.setFill()
        NSRectFill(self.bounds)
        
        let points = self.datasource.points
        let base = self.datasource.low
        let sorted = self.datasource.sortByPolarAngle(points: points, base: base!)
        
        let hull = self.datasource.calculateHull(points: sorted, base: base!)
        
        if let context = NSGraphicsContext.current()?.cgContext {
            for p in self.datasource.points {
                self.drawPoint(context: context, point: p, color: NSColor.red)
            }
            self.drawPoint(context: context, point: self.datasource.low, color: NSColor.blue)
            
            let path = NSBezierPath()
            path.lineWidth = 5.0
    
            var iterator = hull.makeIterator()
            var p = iterator.next()
            path.move(to: p!.value)
            p = iterator.next()
            while p != nil {
                path.line(to: p!.value)
                p = iterator.next()
            }
            path.close()
            path.stroke()
        }
    }
    
    func refresh() {
        self.loadDatasource()
        self.setNeedsDisplay(self.bounds)
    }
}

extension ConvexHullView {
    func drawText(text:String, atPoint point:CGPoint) {
        let attrText = NSAttributedString(string: text)
        attrText.draw(at: point)
    }
    
    func drawPoint(context:CGContext, point:CGPoint, color:NSColor) {
        let rect = NSRect(x: point.x-5.0, y: point.y-5.0, width: 10.0, height: 10.0)
        let path = NSBezierPath(ovalIn: rect)
        color.setFill()
        path.fill()
    }
}
