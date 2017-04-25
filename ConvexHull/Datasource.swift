//
//  Datasource.swift
//  ConvexHull
//
//  Created by Ariel Rodriguez on 3/3/17.
//  Copyright © 2017 VolonBolon. All rights reserved.
//

import Foundation
import LinkedList // https://github.com/volonbolon/refactored-octo-carnival

class Datasource {
    var low:CGPoint!
    var points:[CGPoint] = []
    
    init(limitsOrPoints:Either<Limits,[CGPoint]>) {
        switch limitsOrPoints {
        case .Left(let limits):
            self.points = self.randomizePoints(limits: limits)
        case .Right(let points):
            self.points = points
        }

        let lowestIndex = self.findLowest()
        self.low = self.points[lowestIndex]
        self.points.remove(at: lowestIndex)
    }
}

extension Datasource {
    fileprivate func randomizePoints(limits:Limits) -> [CGPoint] {
        let ll = limits.lowerLeft
        let ur = limits.upperRight
        var points:[CGPoint] = []
        for _ in 0..<limits.qty {
            let x = CGFloat(arc4random_uniform(ur.x - ll.x) + ll.x)
            let y = CGFloat(arc4random_uniform(ur.y - ll.y) + ll.y)
            let p = CGPoint(x: x, y: y)
            points.append(p)
        }
        return points
    }
}

extension Datasource {
    func findLowest() -> Int {
        guard self.points.count > 1 else { return NSNotFound }
        
        var lowestIndex = 0
        var lowest = self.points.first!
        for (i, p) in self.points.enumerated() {
            if p.y < lowest.y {
                lowest = p
                lowestIndex = i
            }
        }
        return lowestIndex
    }
}

extension Datasource {
    func sortByPolarAngle(points:[CGPoint], base:CGPoint) -> [CGPoint] {
        func sortByPolarAngle(p0:CGPoint, p1:CGPoint) -> Bool {
            guard p0 != p1 else { return true }
            let p0ADeltaY = Double(p0.y - base.y)
            let p0ADeltaX = Double(p0.x - base.x)
            
            let p1ADeltaY = Double(p1.y - base.y)
            let p1ADeltaX = Double(p1.x - base.x)
            
            let p0angle = atan2(p0ADeltaY, p0ADeltaX)
            let p1angle = atan2(p1ADeltaY, p1ADeltaX)
            
            if p0angle == p1angle {
                return p0.y > p1.y
            }
            return p0angle > p1angle
        }
        let sortedPoints = points.sorted(by: sortByPolarAngle)
        return sortedPoints
    }
}

extension Datasource {
    // 2D cross product of OA and OB vectors, i.e. z-component of their 3D cross product.
    // Returns a positive value, if OAB makes a counter-clockwise turn,
    // negative for clockwise turn, and zero if the points are collinear.
    // http://mathworld.wolfram.com/Collinear.html
    func cross(P: CGPoint, A: CGPoint, B: CGPoint) -> CGFloat {
        let part1 = (A.x - P.x) * (B.y - P.y)
        let part2 = (A.y - P.y) * (B.x - P.x)
        return  part1 - part2;
    }
    
    func isAntiClockwise(hull:LinkedList<CGPoint>, b:CGPoint) -> Bool {
        let t = hull.lastTwo()!
        let p = t.1.value
        let a = t.0.value
        let cross = self.cross(P: p, A: a, B: b)
        let antiClockwise = cross >= 0.0
        return antiClockwise
    }
    
    
    func calculateHull(points:[CGPoint], base:CGPoint) -> LinkedList<CGPoint> {
        let hull:LinkedList<CGPoint> = LinkedList()
        
        // three points *known* to be on the hull are (in this order) the
        // point with lowest polar angle (points.last), the lowest point (base)
        // and the point with the higher polar angle (points.first)
        hull.append(value: points.last!)
        hull.append(value: base)

        for i in 0..<points.count {
            let b = points[i]
            while self.isAntiClockwise(hull: hull, b: b) {
                hull.dropLast()
            }
            hull.append(value: b)
        }
        
        // because we already have the last point in the hull
        hull.dropLast()
        
        return hull
    }
}


extension LinkedList {
    func lastTwo() -> (NodeType, NodeType)? {
        guard self.count >= 2 else {
            return nil
        }
        let t = (self.nodeAt(index: self.count-1), self.nodeAt(index: self.count-2))
        return t
    }
}
