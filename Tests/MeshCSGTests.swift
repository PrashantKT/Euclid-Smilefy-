//
//  MeshCSGTests.swift
//  GeometryScriptTests
//
//  Created by Nick Lockwood on 31/10/2018.
//  Copyright © 2018 Nick Lockwood. All rights reserved.
//

@testable import Euclid
import XCTest

class MeshCSGTests: XCTestCase {
    // MARK: Subtraction

    func testSubtractCoincidingBoxes() {
        let a = Mesh.cube()
        let b = Mesh.cube()
        let c = a.subtracting(b)
        XCTAssert(c.polygons.isEmpty)
        XCTAssertEqual(c, .difference([a, b]))
    }

    func testSubtractCoincidingBoxesWhenTriangulated() {
        let a = Mesh.cube().triangulate()
        let b = Mesh.cube().triangulate()
        let c = a.subtracting(b)
        XCTAssert(c.polygons.isEmpty)
        XCTAssertEqual(c, .difference([a, b]))
    }

    func testSubtractAdjacentBoxes() {
        let a = Mesh.cube()
        let b = Mesh.cube().translated(by: .unitX)
        let c = a.subtracting(b)
        XCTAssertEqual(c.bounds, a.bounds)
        XCTAssertEqual(c, .difference([a, b]))
    }

    func testSubtractOverlappingBoxes() {
        let a = Mesh.cube()
        let b = Mesh.cube().translated(by: Vector(0.5, 0, 0))
        let c = a.subtracting(b)
        XCTAssertEqual(c.bounds, Bounds(
            min: Vector(-0.5, -0.5, -0.5),
            max: Vector(0, 0.5, 0.5)
        ))
        XCTAssertEqual(c, .difference([a, b]))
    }

    func testSubtractEmptyMesh() {
        let a = Mesh.empty
        let b = Mesh.cube()
        XCTAssertEqual(a.subtracting(b), a)
        XCTAssertEqual(b.subtracting(a), b)
        XCTAssertEqual(a.subtracting(b), .difference([a, b]))
        XCTAssertEqual(b.subtracting(a), .difference([b, a]))
    }

    func testSubtractIsDeterministic() {
        let a = Mesh.cube(size: 0.8)
        let b = Mesh.sphere(slices: 16)
        let c = a.subtracting(b)
        #if !arch(wasm32)
        XCTAssertEqual(c.polygons.count, 189)
        #endif
        XCTAssertEqual(c, .difference([a, b]))
    }

    func testDifferenceOfOne() {
        let mesh = Mesh.cube()
        XCTAssertEqual(mesh, .difference([mesh]))
    }

    func testDifferenceOfNone() {
        XCTAssertEqual(Mesh.empty, .difference([]))
    }

    // MARK: Symmetric Difference (XOR)

    func testXorCoincidingCubes() {
        let a = Mesh.cube()
        let b = Mesh.cube()
        let c = a.symmetricDifference(b)
        XCTAssert(c.polygons.isEmpty)
        XCTAssertEqual(c, .symmetricDifference([a, b]))
    }

    func testXorAdjacentCubes() {
        let a = Mesh.cube()
        let b = Mesh.cube().translated(by: .unitX)
        let c = a.symmetricDifference(b)
        XCTAssertEqual(c.bounds, a.bounds.union(b.bounds))
        XCTAssertEqual(c, .symmetricDifference([a, b]))
    }

    func testXorOverlappingCubes() {
        let a = Mesh.cube()
        let b = Mesh.cube().translated(by: Vector(0.5, 0, 0))
        let c = a.symmetricDifference(b)
        XCTAssertEqual(c.bounds, Bounds(
            min: Vector(-0.5, -0.5, -0.5),
            max: Vector(1.0, 0.5, 0.5)
        ))
        XCTAssertEqual(c, .symmetricDifference([a, b]))
    }

    func testXorWithEmptyMesh() {
        let a = Mesh.empty
        let b = Mesh.cube()
        XCTAssertEqual(a.symmetricDifference(b), b)
        XCTAssertEqual(b.symmetricDifference(a), b)
        XCTAssertEqual(a.symmetricDifference(b), .symmetricDifference([a, b]))
        XCTAssertEqual(b.symmetricDifference(a), .symmetricDifference([b, a]))
    }

    func testXorIsDeterministic() {
        let a = Mesh.cube(size: 0.8)
        let b = Mesh.sphere(slices: 16)
        let c = a.symmetricDifference(b)
        #if !arch(wasm32)
        XCTAssertEqual(c.polygons.count, 323)
        #endif
        XCTAssertEqual(c, .symmetricDifference([a, b]))
    }

    func testXorOfOne() {
        let mesh = Mesh.cube()
        XCTAssertEqual(mesh, .symmetricDifference([mesh]))
    }

    func testXorOfNone() {
        XCTAssertEqual(Mesh.empty, .symmetricDifference([]))
    }

    // MARK: Union

    func testUnionOfCoincidingBoxes() {
        let a = Mesh.cube()
        let b = Mesh.cube()
        let c = a.union(b)
        XCTAssertEqual(c.bounds, a.bounds)
        XCTAssertEqual(c, .union([a, b]))
    }

    func testUnionOfAdjacentBoxes() {
        let a = Mesh.cube()
        let b = Mesh.cube().translated(by: .unitX)
        let c = a.union(b)
        XCTAssertEqual(c.bounds, a.bounds.union(b.bounds))
        XCTAssertEqual(c, .union([a, b]))
    }

    func testUnionOfOverlappingBoxes() {
        let a = Mesh.cube()
        let b = Mesh.cube().translated(by: Vector(0.5, 0, 0))
        let c = a.union(b)
        XCTAssertEqual(c.bounds, Bounds(
            min: Vector(-0.5, -0.5, -0.5),
            max: Vector(1, 0.5, 0.5)
        ))
        XCTAssertEqual(c, .union([a, b]))
    }

    func testUnionWithEmptyMesh() {
        let a = Mesh.empty
        let b = Mesh.cube()
        XCTAssertEqual(a.union(b).bounds, b.bounds)
        XCTAssertEqual(b.union(a).bounds, b.bounds)
        XCTAssertEqual(a.union(b), .union([a, b]))
        XCTAssertEqual(b.union(a), .union([b, a]))
    }

    func testUnionIsDeterministic() {
        let a = Mesh.cube(size: 0.8)
        let b = Mesh.sphere(slices: 16)
        let c = a.union(b)
        #if !arch(wasm32)
        XCTAssertEqual(c.polygons.count, 237)
        #endif
        XCTAssertEqual(c, .union([a, b]))
    }

    func testUnionOfOne() {
        let mesh = Mesh.cube()
        XCTAssertEqual(mesh, .union([mesh]))
    }

    func testUnionOfNone() {
        XCTAssertEqual(Mesh.empty, .union([]))
    }

    // MARK: Intersection

    func testIntersectionOfCoincidingBoxes() {
        let a = Mesh.cube()
        let b = Mesh.cube()
        let c = a.intersection(b)
        XCTAssertEqual(c.bounds, a.bounds)
        XCTAssertEqual(c, .intersection([a, b]))
    }

    func testIntersectionOfAdjacentBoxes() {
        let a = Mesh.cube()
        let b = Mesh.cube().translated(by: .unitX)
        let c = a.intersection(b)
        // TODO: ideally this should probably be empty, but it's not clear
        // how to achieve that while also getting desired planar behavior
        XCTAssertEqual(c.bounds, Bounds(
            min: Vector(0.5, -0.5, -0.5),
            max: Vector(0.5, 0.5, 0.5)
        ))
        XCTAssertEqual(c, .intersection([a, b]))
    }

    func testIntersectionOfOverlappingBoxes() {
        let a = Mesh.cube()
        let b = Mesh.cube().translated(by: Vector(0.5, 0, 0))
        let c = a.intersection(b)
        XCTAssertEqual(c.bounds, Bounds(
            min: Vector(0, -0.5, -0.5),
            max: Vector(0.5, 0.5, 0.5)
        ))
        XCTAssertEqual(c, .intersection([a, b]))
    }

    func testIntersectionOfNonOverlappingBoxes() {
        let a = Mesh.cube()
        let b = Mesh.cube().translated(by: Vector(2, 0, 0))
        let c = a.intersection(b)
        XCTAssertEqual(c, .empty)
        XCTAssertEqual(c, .intersection([a, b]))
    }

    func testIntersectionWithEmptyMesh() {
        let a = Mesh.empty
        let b = Mesh.cube()
        XCTAssert(a.intersection(b).bounds.isEmpty)
        XCTAssert(b.intersection(a).bounds.isEmpty)
    }

    func testIntersectIsDeterministic() {
        let a = Mesh.cube(size: 0.8)
        let b = Mesh.sphere(slices: 16)
        let c = a.intersection(b)
        XCTAssertEqual(c.polygons.count, 86)
        XCTAssertEqual(c, .intersection([a, b]))
    }

    func testIntersectonOfOne() {
        let mesh = Mesh.cube()
        XCTAssertEqual(mesh, .intersection([mesh]))
    }

    func testIntersectionOfNone() {
        XCTAssertEqual(Mesh.empty, .intersection([]))
    }

    // MARK: Planar subtraction

    func testSubtractCoincidingSquares() {
        let a = Mesh.fill(.square())
        let b = Mesh.fill(.square())
        let c = a.subtracting(b)
        XCTAssert(c.polygons.isEmpty)
        XCTAssertEqual(c, .difference([a, b]))
    }

    func testSubtractAdjacentSquares() {
        let a = Mesh.fill(.square())
        let b = Mesh.fill(.square()).translated(by: .unitX)
        let c = a.subtracting(b)
        XCTAssertEqual(c.bounds, a.bounds)
        XCTAssertEqual(c, .difference([a, b]))
    }

    func testSubtractOverlappingSquares() {
        let a = Mesh.fill(.square())
        let b = Mesh.fill(.square()).translated(by: Vector(0.5, 0, 0))
        let c = a.subtracting(b)
        XCTAssertEqual(c.bounds, Bounds(
            min: Vector(-0.5, -0.5, 0),
            max: Vector(0, 0.5, 0)
        ))
        XCTAssertEqual(c, .difference([a, b]))
    }

    // MARK: Planar XOR

    func testXorCoincidingSquares() {
        let a = Mesh.fill(.square())
        let b = Mesh.fill(.square())
        let c = a.symmetricDifference(b)
        XCTAssert(c.polygons.isEmpty)
        XCTAssertEqual(c, .symmetricDifference([a, b]))
    }

    func testXorAdjacentSquares() {
        let a = Mesh.fill(.square())
        let b = Mesh.fill(.square()).translated(by: .unitX)
        let c = a.symmetricDifference(b)
        XCTAssertEqual(c.bounds, a.bounds.union(b.bounds))
        XCTAssertEqual(c, .symmetricDifference([a, b]))
    }

    func testXorOverlappingSquares() {
        let a = Mesh.fill(.square())
        let b = Mesh.fill(.square()).translated(by: Vector(0.5, 0, 0))
        let c = a.symmetricDifference(b)
        XCTAssertEqual(c.bounds, Bounds(
            min: Vector(-0.5, -0.5, 0),
            max: Vector(1.0, 0.5, 0)
        ))
        XCTAssertEqual(c, .symmetricDifference([a, b]))
    }

    // MARK: Planar union

    func testUnionOfCoincidingSquares() {
        let a = Mesh.fill(.square())
        let b = Mesh.fill(.square())
        let c = a.union(b)
        XCTAssertEqual(c.bounds, a.bounds)
        XCTAssertEqual(c, .union([a, b]))
    }

    func testUnionOfAdjacentSquares() {
        let a = Mesh.fill(.square())
        let b = Mesh.fill(.square()).translated(by: .unitX)
        let c = a.union(b)
        XCTAssertEqual(c.bounds, a.bounds.union(b.bounds))
        XCTAssertEqual(c, .union([a, b]))
    }

    func testUnionOfOverlappingSquares() {
        let a = Mesh.fill(.square())
        let b = Mesh.fill(.square()).translated(by: Vector(0.5, 0, 0))
        let c = a.union(b)
        XCTAssertEqual(c.bounds, Bounds(
            min: Vector(-0.5, -0.5, 0),
            max: Vector(1, 0.5, 0)
        ))
        XCTAssertEqual(c, .union([a, b]))
    }

    // MARK: Planar intersection

    func testIntersectionOfCoincidingSquares() {
        let a = Mesh.fill(.square())
        let b = Mesh.fill(.square())
        let c = a.intersection(b)
        XCTAssertEqual(c.bounds, a.bounds)
        XCTAssertEqual(c, .intersection([a, b]))
    }

    func testIntersectionOfAdjacentSquares() {
        let a = Mesh.fill(.square())
        let b = Mesh.fill(.square()).translated(by: .unitX)
        let c = a.intersection(b)
        XCTAssert(c.polygons.isEmpty)
        XCTAssertEqual(c, .intersection([a, b]))
    }

    func testIntersectionOfOverlappingSquares() {
        let a = Mesh.fill(.square())
        let b = Mesh.fill(.square()).translated(by: Vector(0.5, 0, 0))
        let c = a.intersection(b)
        XCTAssertEqual(c.bounds, Bounds(
            min: Vector(0, -0.5, 0),
            max: Vector(0.5, 0.5, 0)
        ))
        XCTAssertEqual(c, .intersection([a, b]))
    }

    // MARK: Plane clipping

    func testSquareClippedToPlane() {
        let a = Mesh.fill(.square())
        let plane = Plane(unchecked: .unitX, pointOnPlane: .zero)
        let b = a.clip(to: plane)
        XCTAssertEqual(b.bounds, .init(Vector(0, -0.5), Vector(0.5, 0.5)))
    }

    func testPentagonClippedToPlane() {
        let a = Mesh.fill(.circle(segments: 5))
        let plane = Plane(unchecked: .unitX, pointOnPlane: .zero)
        let b = a.clip(to: plane)
        XCTAssertEqual(b.bounds, .init(
            Vector(0, -0.404508497187),
            Vector(0.475528258148, 0.5)
        ))
    }

    func testDiamondClippedToPlane() {
        let a = Mesh.fill(.circle(segments: 4))
        let plane = Plane(unchecked: .unitX, pointOnPlane: .zero)
        let b = a.clip(to: plane)
        XCTAssertEqual(b.bounds, .init(Vector(0, -0.5), Vector(0.5, 0.5)))
    }

    func testSquareClippedToItsOwnPlane() {
        let a = Mesh.fill(.square())
        let plane = Plane(unchecked: .unitZ, pointOnPlane: .zero)
        let b = a.clip(to: plane)
        XCTAssertEqual(b.polygons, [a.polygons[0]])
    }

    func testSquareClippedToItsOwnPlaneWithFill() {
        let a = Mesh.fill(.square())
        let plane = Plane(unchecked: .unitZ, pointOnPlane: .zero)
        let b = a.clip(to: plane, fill: Color.white)
        XCTAssertEqual(b.polygons.first, a.polygons[0])
        guard b.polygons.count == 2 else {
            XCTFail()
            return
        }
        XCTAssertEqual(b.polygons[1].bounds, a.polygons[1].bounds)
    }

    func testSquareClippedToReversePlane() {
        let a = Mesh.fill(.square())
        let plane = Plane(unchecked: -.unitZ, pointOnPlane: .zero)
        let b = a.clip(to: plane)
        XCTAssertEqual(b.polygons, [a.polygons[1]])
    }

    func testSquareClippedToReversePlaneWithFill() {
        let a = Mesh.fill(.square())
        let plane = Plane(unchecked: -.unitZ, pointOnPlane: .zero)
        let b = a.clip(to: plane, fill: Color.white)
        XCTAssertEqual(b.polygons.first?.bounds, a.polygons[0].bounds)
        guard b.polygons.count == 2 else {
            XCTFail()
            return
        }
        XCTAssertEqual(b.polygons[1].bounds, a.polygons[1].bounds)
    }

    // MARK: Plane splitting

    func testSquareSplitAlongPlane() {
        let a = Mesh.fill(.square())
        let plane = Plane(unchecked: .unitX, pointOnPlane: .zero)
        let b = a.split(along: plane)
        XCTAssertEqual(b.0?.bounds, .init(Vector(0, -0.5), Vector(0.5, 0.5)))
        XCTAssertEqual(b.1?.bounds, .init(Vector(-0.5, -0.5), Vector(0, 0.5)))
        XCTAssertEqual(b.front, b.0)
        XCTAssertEqual(b.back, b.1)
    }

    func testSquareSplitAlongItsOwnPlane() {
        let a = Mesh.fill(.square())
        let plane = Plane(unchecked: .unitZ, pointOnPlane: .zero)
        let b = a.split(along: plane)
        XCTAssertEqual(b.front?.polygons, [a.polygons[0]])
        XCTAssertEqual(b.back?.polygons, [a.polygons[1]])
    }

    func testSquareSplitAlongReversePlane() {
        let a = Mesh.fill(.square())
        let plane = Plane(unchecked: -.unitZ, pointOnPlane: .zero)
        let b = a.split(along: plane)
        XCTAssertEqual(b.front?.polygons, [a.polygons[1]])
        XCTAssertEqual(b.back?.polygons, [a.polygons[0]])
    }

    // MARK: Submeshes

    func testUnionSubmeshes() {
        let a = Mesh.cube()
        let b = Mesh.cube().translated(by: Vector(2, 0, 0))
        let c = a.union(b)
        let d = Mesh.cube().translated(by: Vector(4, 0, 0))
        XCTAssertEqual(c.union(d).submeshes.count, 3)
    }

    func testUnionOfPrecalculatedSubmeshes() {
        let a = Mesh.cube()
        _ = a.submeshes
        let b = Mesh.cube().translated(by: Vector(2, 0, 0))
        _ = b.submeshes
        let c = a.union(b)
        XCTAssertEqual(c.submeshes.count, 2)
        let d = Mesh.cube().translated(by: Vector(4, 0, 0))
        XCTAssertEqual(c.union(d).submeshes.count, 3)
    }
}
