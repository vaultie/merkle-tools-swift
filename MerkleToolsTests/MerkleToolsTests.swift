//
//  MerkleToolsTests.swift
//  MerkleToolsTests
//
//  Created by Nikita Plakhotin on 2019-12-13.
//  Copyright © 2019 Vaultie Inc. All rights reserved.
//

import XCTest
@testable import MerkleTools

class MerkleToolsTests: XCTestCase {
    
    var merkleTools: MerkleTools!

    override func setUp() {
        merkleTools = MerkleTools()
    }
    
    override func tearDown() {
        merkleTools = MerkleTools()
    }

    func testAddLeafAndGetLeaf() {
        let testLeafValue = "This is a test leaf"
        let testLeaf = merkleTools.sha256(data: testLeafValue.data(using: .utf8)!)
        merkleTools.addLeaf(value: testLeafValue, doHash: true)
        
        XCTAssertEqual(merkleTools.getLeaf(index: 0), testLeaf)
        
        XCTAssertEqual(merkleTools.getLeaf(index: 1), nil)
        XCTAssertEqual(merkleTools.getLeaf(index: -1), nil)
    }
    
    func testAddLeaves() {
        let testLeafValues = ["This is first test leaf", "This is second test leaf"]
        var testLeaves: [Data] = []
        for leaf in testLeafValues {
            testLeaves.append(merkleTools.sha256(data: leaf.data(using: .utf8)!))
        }
        merkleTools.addLeaves(valuesArray: testLeafValues, doHash: true)
        
        for i in 0..<testLeaves.count {
            XCTAssertEqual(merkleTools.getLeaf(index: i), testLeaves[i])
        }
    }
    
    func testLeafCount() {
        let testLeafCount = 10
        var testLeaves: [String] = []
        for i in 0..<testLeafCount {
            testLeaves.append("This is a test leaf \(i)")
        }
        merkleTools.addLeaves(valuesArray: testLeaves, doHash: true)
        
        XCTAssertEqual(merkleTools.getLeafCount(), testLeafCount)
    }
    
    func testGetTreeReadyState() {
        XCTAssertEqual(merkleTools.getTreeReadyState(), false)
        merkleTools.makeTree(doubleHash: false)
        
        XCTAssertEqual(merkleTools.getTreeReadyState(), true)
    }
    
    func testGetMerkleRoot() {
        let testLeafCount = 10
        var testLeaves: [String] = []
        for i in 0..<testLeafCount {
            testLeaves.append("This is a test leaf \(i)")
        }
        let testMerkleRoot = "669e95eda84fc547fc724f8b6f385b258aabbec2076039ce313fd3877e103705"
        merkleTools.addLeaves(valuesArray: testLeaves, doHash: true)
        merkleTools.makeTree(doubleHash: true)
        
        XCTAssertEqual(merkleTools.getMerkleRoot()?.hexEncodedString(), testMerkleRoot)
        
        merkleTools.resetTree()
        XCTAssertEqual(merkleTools.getMerkleRoot(), nil)
    }
    
    func testGetProof() {
        let testLeafCount = 10
        var testLeaves: [String] = []
        for i in 0..<testLeafCount {
            testLeaves.append("This is a test leaf \(i)")
        }
        let testProof: [(String, String)] = [
            ("left", "dc74f957f881fda1be8facbb56f823682aa28057d5679eb1f08a50de459a727f"),
            ("right", "2468048e9d1c884f2033587629a8a5c9ff946a151bab6a9cae2a6187984d4252"),
            ("left", "5a88ed7623570a7bf1148a7195c055e5ae79be7327bf78014faf3f5ffcd260d7"),
            ("right","20b6e8b9519602774882e3a176bbd20c00fe30da9af039bb37a2d02e087713a0")
        ]
        merkleTools.addLeaves(valuesArray: testLeaves, doHash: true)
        merkleTools.makeTree(doubleHash: true)
        let proof = merkleTools.getProof(index: 5)
        var proofsAreEqual = true
        for i in 0..<testProof.count {
            if testProof[i].0 != proof![i].0 || testProof[i].1 != proof![i].1 {
                proofsAreEqual = false
            }
        }
        
        XCTAssert(proofsAreEqual)
        
        var failCase = merkleTools.getProof(index: -1) == nil
        XCTAssert(failCase)
        failCase = merkleTools.getProof(index: testLeafCount + 1) == nil
        XCTAssert(failCase)
        merkleTools.resetTree()
        failCase = merkleTools.getProof(index: 0) == nil
        XCTAssert(failCase)
    }
    
    func testValidateProof() {
        let testLeafCount = 10
        let validateLeafIndex = 5
        var testLeaves: [String] = []
        for i in 0..<testLeafCount {
            testLeaves.append("This is a test leaf \(i)")
        }
        merkleTools.addLeaves(valuesArray: testLeaves, doHash: true)
        merkleTools.makeTree(doubleHash: true)
        let isValid = merkleTools.validateProof(proof: merkleTools.getProof(index: validateLeafIndex)!,
                                                targetHash: merkleTools.getLeaf(index: validateLeafIndex)!,
                                                merkleRoot: merkleTools.getMerkleRoot()!, doubleHash: true)
        
        XCTAssert(isValid)
    }
    
    func testResetTree() {
        merkleTools.addLeaf(value: "This is a test leaf", doHash: true)
        merkleTools.resetTree()
        
        XCTAssertEqual(merkleTools.tree, MerkleTools().tree)
    }
    
}
