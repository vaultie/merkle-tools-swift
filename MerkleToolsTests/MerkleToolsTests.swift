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

    func testAddLeaf() {
        let leafValue = "This is a test leaf"
        let leaf = merkleTools.sha256(data: leafValue.data(using: .utf8)!)
        merkleTools.addLeaf(value: leafValue, doHash: true)
        XCTAssertEqual(merkleTools.getLeaf(index: 0), leaf)
    }
}
