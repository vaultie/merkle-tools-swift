//
//  MerkleTree.swift
//  MerkleTools
//
//  Created by Nikita Plakhotin on 2019-12-13.
//  Copyright © 2019 Vaultie Inc. All rights reserved.
//

import UIKit

class MerkleTree: NSObject {
    var leaves: [Data] = []
    var levels: [[Data]] = []
    var isReady: Bool = false
}
