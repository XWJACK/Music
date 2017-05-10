//
//  FoundationExtension.swift
//  Music
//
//  Created by Jack on 5/10/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation

extension String {
    /// MD5
    ///
    /// For more information about import C library into Framework:
    /// http://stackoverflow.com/questions/25248598/importing-commoncrypto-in-a-swift-framework/37125785#37125785 and
    /// https://github.com/onmyway133/Arcane
    ///
    /// - returns: nil `iff` encoding is not utf8
    public func md5() -> String? {
        guard let messageData = self.data(using:String.Encoding.utf8) else { return nil }
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension Double {
    var float: Float { return Float(self) }
}

extension TimeInterval {
    var musicTime: String {
        let date = Date(timeIntervalSinceReferenceDate: self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        return dateFormatter.string(from: date)
    }
}
