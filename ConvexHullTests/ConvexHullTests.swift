//
//  ConvexHullTests.swift
//  ConvexHullTests
//
//  Created by Ariel Rodriguez on 2/5/17.
//  Copyright © 2017 VolonBolon. All rights reserved.
//

import XCTest
@testable import ConvexHull

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

class ConvexHullTests: XCTestCase {
    let points:[CGPoint] = [
        CGPoint(x: 0, y: 4), // 0
        CGPoint(x: 0.8, y: 7.8), // 1
        CGPoint(x: 1.5, y: 5.5), // 2
        CGPoint(x: 2.1, y: 0.5), // 3
        CGPoint(x: 2.5, y: 9.1), // 4
        CGPoint(x: 4.0, y: 3.8), // 5
        CGPoint(x: 4.4, y: 8.2), // 6
        CGPoint(x: 6.5, y: 10.0), // 7
        CGPoint(x: 7.0, y: 1.1), // 8
        CGPoint(x: 7.3, y: 6.4), // 9
        CGPoint(x: 8.0, y: 8.8), // 10
        CGPoint(x: 9.1, y: 3.8), // 11
        CGPoint(x: 10.3, y: 5.4), // 12
        CGPoint(x: 10.5, y: 8.9), // 13
        CGPoint(x: 11.8, y: 2.2), // 14
    ]
    
    var datasource:Datasource!

    override func setUp() {
        super.setUp()
        
        let shuffledPoints = self.points.shuffled()
        let e:Either<Limits,[CGPoint]> = .Right(shuffledPoints)
        self.datasource = Datasource(limitsOrPoints:e)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRandom() {
        let ll = IntPoint(x: 10, y: 10)
        let ur = IntPoint(x: 20, y: 20)
        let limits = Limits(lowerLeft: ll, upperRight: ur)
        let e:Either<Limits,[CGPoint]> = .Left(limits)
        let datasource = Datasource(limitsOrPoints:e)
        XCTAssert(datasource.points.count == 19, "There should be 19 points + low")
        XCTAssertNotNil(datasource.low, "low should not be nil")
    }
    
    func testLowest() {
        let low = self.datasource.low
        XCTAssert(low == self.points[3])
    }
    
    func testSortByPolar() {
        let points = self.datasource.points
        let low = self.datasource.low
        let sortedPoints = self.datasource.sortByPolarAngle(points: points, base: low!)
        
        let p0 = sortedPoints[0]
        XCTAssertTrue(p0.x==0.0 && p0.y==4.0, "p0:\(p0) should be (0.0, 4.0")
        
        let p1 = sortedPoints[1]
        XCTAssertTrue(p1.x==0.8 && p1.y==7.8, "p1:\(p1) should be (0.8, 7.8")
        
        let p2 = sortedPoints[2]
        XCTAssertTrue(p2.x==1.5 && p2.y==5.5, "p2:\(p2) should be (1.5, 4.0")

        let p3 = sortedPoints[3]
        XCTAssertTrue(p3.x==2.5 && p3.y==9.1, "p3:\(p3) should be (2.5, 9.1")

        let p4 = sortedPoints[4]
        XCTAssertTrue(p4.x==4.4 && p4.y==8.2, "p4:\(p4) should be (4.4, 8.2")

        let p5 = sortedPoints[5]
        XCTAssertTrue(p5.x==6.5 && p5.y==10.0, "p5:\(p5) should be (6.5, 10.0")
        
        let p6 = sortedPoints[6]
        XCTAssertTrue(p6.x==4.0 && p6.y==3.8, "p6:\(p6) should be (4.0, 3.8")
        
        let p7 = sortedPoints[7]
        XCTAssertTrue(p7.x==8.0 && p7.y==8.8, "p7:\(p7) should be (8.0, 8.8")
        
        let p8 = sortedPoints[8]
        XCTAssertTrue(p8.x==7.3 && p8.y==6.4, "p8:\(p8) should be (7.3, 6.4")
        
        let p9 = sortedPoints[9]
        XCTAssertTrue(p9.x==10.5 && p9.y==8.9, "p9:\(p9) should be (10.5, 8.9")
        
        let p10 = sortedPoints[10]
        XCTAssertTrue(p10.x==10.3 && p10.y==5.4, "p10:\(p10) should be (10.3, 5.4")
        
        let p11 = sortedPoints[11]
        XCTAssertTrue(p11.x==9.1 && p11.y==3.8, "p11:\(p11) should be (9.1, 3.8")
        
        let p12 = sortedPoints[12]
        XCTAssertTrue(p12.x==11.8 && p12.y==2.2, "p12:\(p12) should be (11.8, 2.2")
        
        let p13 = sortedPoints[13]
        XCTAssertTrue(p13.x==7.0 && p13.y==1.1, "p13:\(p13) should be (7.0, 1.1")
    }
    
    func testCross() {
        let p1 = CGPoint(x: 2, y: 12)
        let p2 = CGPoint(x: 4, y: 24)
        let p3 = CGPoint(x: 6, y: 36)
        
        // these three points are collinear
        let cross1 = self.datasource.cross(P: p1, A: p2, B: p3)
        XCTAssertTrue(cross1 == 0.0, "\(cross1) should be 0.0")
        
        // here we have a clockwise turn
        let p4 = CGPoint(x: 6, y: 30)
        let cross2 = self.datasource.cross(P: p1, A: p2, B: p4)
        XCTAssertTrue(cross2 < 0.0, "\(cross2) should be 0.0")
        
        // here we have a anticlockwise turn
        let p5 = CGPoint(x: 6, y: 38)
        let cross3 = self.datasource.cross(P: p1, A: p2, B: p5)
        XCTAssertTrue(cross3 > 0.0, "\(cross3) should be 0.0")
        
        let p6 = CGPoint(x: 7.1, y: 1.0)
        let p7 = CGPoint(x: 2.1, y: 0.5)
        let p8 = CGPoint(x: 0.0, y: 4.0)
        
        let cross4 = self.datasource.cross(P: p6, A: p7, B: p8)
        XCTAssertTrue(cross4 < 0.0, "\(cross4) should be 0.0")
    }
    
    func testHull() {
        let points = self.datasource.points
        let low = self.datasource.low!
        let sortedPoints = self.datasource.sortByPolarAngle(points: points, base: low)
        let hull = self.datasource.calculateHull(points: sortedPoints, base: low)
        XCTAssertTrue(hull.count == 8, "hull count \(hull.count) should be 8")
        
        let p1 = CGPoint(x:7.0, y:1.1)
        let n1 = hull.nodeAt(index: 0).value
        XCTAssertTrue(n1 == p1, "n1 (\(n1) should be \(p1)")
        
        let p2 = CGPoint(x:2.1, y:0.5)
        let n2 = hull.nodeAt(index: 1).value
        XCTAssertTrue(n2 == p2, "n2 (\(n2) should be \(p2)")
        
        let p3 = CGPoint(x:0.0, y:4.0)
        let n3 = hull.nodeAt(index: 2).value
        XCTAssertTrue(n3 == p3, "n3 (\(n3) should be \(p3)")
        
        let p4 = CGPoint(x:0.8, y:7.8)
        let n4 = hull.nodeAt(index: 3).value
        XCTAssertTrue(n4 == p4, "n4 (\(n4) should be \(p4)")
        
        let p5 = CGPoint(x:2.5, y:9.1)
        let n5 = hull.nodeAt(index: 4).value
        XCTAssertTrue(n5 == p5, "n5 (\(n5) should be \(p5)")
        
        let p6 = CGPoint(x:6.5, y:10)
        let n6 = hull.nodeAt(index: 5).value
        XCTAssertTrue(n6 == p6, "n6 (\(n6) should be \(p6)")
        
        let p7 = CGPoint(x:10.5, y:8.9)
        let n7 = hull.nodeAt(index: 6).value
        XCTAssertTrue(n7 == p7, "n7 (\(n7) should be \(p7)")
        
        let p8 = CGPoint(x:11.8, y:2.2)
        let n8 = hull.nodeAt(index: 7).value
        XCTAssertTrue(n8 == p8, "n8 (\(n8) should be \(p8)")
    }
}
