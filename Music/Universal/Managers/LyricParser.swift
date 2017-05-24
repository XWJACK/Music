//
//  LyricParser.swift
//  Music
//
//  Created by Jack on 5/24/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

struct LyricParser {
    
    let rawLyric: String
    
    private(set) var timeLyric: [(time: TimeInterval, lyric: String)] = []
    private(set) var stringLyric: [(time: String, lyric: String)] = []
    
    init(_ rawLyric: String) {
        self.rawLyric = rawLyric
        
        /// "[03:20.140]逆着洋流独自游到底"
        /// "[03:26.700]年少时候虔诚发过的誓"
        let row: [String.CharacterView.SubSequence] = rawLyric.characters.split(separator: "\n")
        
        /// ["03:20.140", "逆着洋流独自游到底"]
        /// ["03:26.700", "年少时候虔诚发过的誓"]
        let clearRow: [[String.CharacterView.SubSequence]] = row.map{ $0.split(separator: "]") }
        let fixRow: [[String.CharacterView.SubSequence]] = clearRow.filter{ $0.count == 2 }.map{ [$0[0].dropFirst(), $0[1]] }
        
        stringLyric = fixRow.map{ (String($0[0]), String($0[1])) }
        
        /// [(200.14, "逆着洋流独自游到底")]
        /// [(206.7, "年少时候虔诚发过的誓")]
        let timeRow: [(TimeInterval, String)] = fixRow.map{ (timeInterval($0[0]), String($0[1])) }
        
        timeLyric = timeRow
    }
    
    private func timeInterval(_ string: String.CharacterView.SubSequence) -> TimeInterval {
        /// [["03"], ["20", "140"]]
        let splitTime: [[String.CharacterView.SubSequence]] = string.split(separator: ":").map{ $0.split(separator: ".") }
        
        /// 3
        let minTime = Double(String(splitTime[0][0])) ?? 0
        /// 20
        let secTime = Double(String(splitTime[1][0])) ?? 0
        /// 140
        let micTime = Double(String(splitTime[1][1])) ?? 0
      
        return minTime * 60 + secTime + micTime / 1000
    }
}
