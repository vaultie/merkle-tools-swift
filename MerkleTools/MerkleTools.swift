//
//  MerkleTools.swift
//  MerkleTools
//
//  Created by Nikita Plakhotin on 2019-12-13.
//  Copyright © 2019 Vaultie Inc. All rights reserved.
//

import Foundation

public final class MerkleTools {
    var tree: MerkleTree!
    
    public init() {
       tree = MerkleTree()
    }
    
    public func resetTree() {
        tree = MerkleTree()
    }
    
    public func addLeaf(value: String, doHash: Bool) {
        tree.isReady = false
        var leafData: Data? = value.data(using: .utf8)
        if doHash {
            leafData = sha256(data: leafData!)
        }
        tree.leaves.append(leafData!)
    }
    
    public func addLeaves(valuesArray: [String], doHash: Bool) {
        for value in valuesArray {
            addLeaf(value: value, doHash: doHash)
        }
    }
    
    public func getLeaf(index: Int) -> Data? {
        if (index < 0 || index > (tree.leaves.count - 1)) {
            return nil
        } else {
            return tree.leaves[index]
        }
    }
    
    public func getLeafCount() -> Int {
        return tree.leaves.count
    }
    
    public func getTreeReadyState() -> Bool {
        return tree.isReady
    }
    
    public func makeTree(doubleHash: Bool) {
        tree.isReady = false
        let leafCount = tree.leaves.count
        if leafCount > 0 {
            tree.levels = []
            tree.levels.insert(tree.leaves, at: 0)
            while tree.levels[0].count > 1 {
                tree.levels.insert(calculateNextLevel(doubleHash: doubleHash), at: 0)
            }
        }
        tree.isReady = true
    }
    
    public func getMerkleRoot() -> Data? {
        if !tree.isReady || tree.levels.count == 0 {
            return nil
        } else {
            return tree.levels[0][0]
        }
    }
    
    // Returns the proof for a leaf at the given index as an array of merkle siblings in hex format
    public func getProof(index: Int) -> [(String, String)]? {
        var currentIndex = index
        if !tree.isReady {
            return nil
        }
        let currentRowIndex = tree.levels.count - 1
        if currentIndex < 0 || currentIndex > tree.levels[currentRowIndex].count - 1 {
            return nil
        }
        var proof: [(String, String)] = []
        for x in stride(from: currentRowIndex, to: 0, by: -1) {
            let currentLevelNodeCount = tree.levels[x].count
            if currentIndex == currentLevelNodeCount - 1 && currentLevelNodeCount % 2 == 1 {
                currentIndex = Int(floor(Double(currentIndex) / 2))
                continue
            }
            
            let isRightNode = (currentIndex % 2) == 1
            let siblingIndex = isRightNode ? (currentIndex - 1) : (currentIndex + 1)
            var sibling: (String, String)
            let siblingPosition = isRightNode ? "left" : "right"
            let siblingValue = tree.levels[x][siblingIndex].hexEncodedString()
            sibling = (siblingPosition, siblingValue)
            
            proof.append(sibling)
            
            currentIndex = Int(floor(Double(currentIndex) / 2))
        }
        return proof
    }
    
    public func validateProof(proof: [(String, String)], targetHash: Data, merkleRoot: Data, doubleHash: Bool) -> Bool {
        if (proof.count == 0) {
            return targetHash.hexEncodedString() == merkleRoot.hexEncodedString()
        }
        var proofHash = targetHash
        for x in 0..<proof.count {
            if proof[x].0 == "left" {
                var combinedData = hexStringToData(hex: proof[x].1)
                combinedData.append(proofHash)
                if doubleHash {
                    proofHash = sha256(data: sha256(data: combinedData))
                } else {
                    proofHash = sha256(data: combinedData)
                }
            } else if proof[x].0 == "right" {
                var combinedData = proofHash
                combinedData.append(hexStringToData(hex: proof[x].1))
                if doubleHash {
                    proofHash = sha256(data: sha256(data: combinedData))
                } else {
                    proofHash = sha256(data: combinedData)
                }
            } else {
                return false
            }
        }
        
        return proofHash.hexEncodedString() == merkleRoot.hexEncodedString()
    }
    
    // Calculates the next level of node when building the merkle tree
    // These values are calcalated off of the current highest level, level 0 and will be prepended to the levels array
    public func calculateNextLevel(doubleHash: Bool) -> [Data] {
        var nodes: [Data] = []
        let topLevel = tree.levels[0]
        let topLevelCount = topLevel.count
        for x in stride(from: 0, to: topLevelCount, by: 2) {
            if (x + 1 <= topLevelCount - 1) { // concatenate and hash the pair, add to the next level array, doubleHash if requested
                if (doubleHash) {
                    nodes.append(sha256(data: sha256(data: topLevel[x] + topLevel[x + 1])))
                } else {
                    nodes.append(sha256(data: topLevel[x] + topLevel[x + 1]))
                }
            } else { // this is an odd ending node, promote up to the next level by itself
                nodes.append(topLevel[x])
            }
        }
        return nodes
    }
    
    public func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
    
    public func hexStringToData(hex: String) -> Data {
        var hex = hex
        var data = Data()
        while(hex.count > 0) {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt64 = 0
            Scanner(string: c).scanHexInt64(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
    
    class MerkleTree: Equatable {
        static func == (lhs: MerkleTree, rhs: MerkleTree) -> Bool {
            if lhs.isReady != rhs.isReady {
                return false
            }
            if lhs.leaves != rhs.leaves {
                return false
            }
            if lhs.levels != rhs.levels {
                 return false
            }
            return true
        }
        
        var leaves: [Data] = []
        var levels: [[Data]] = []
        var isReady: Bool = false
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
