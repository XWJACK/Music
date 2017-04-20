//
//  StreamAudioPlayer.swift
//  Music
//
//  Created by Jack on 4/19/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import Foundation
import AudioToolbox

protocol StreamAudioPlayerDataSource: class {
    func responseData(completedBlock: @escaping (Data) -> ())
}

protocol StreamAudioPlayerDelegate: class {
    
}

class StreamAudioPlayer {
    weak var dataSource: StreamAudioPlayerDataSource?
    weak var delegate: StreamAudioPlayerDelegate?
    
    private var audioFileStreamID: AudioFileStreamID? = nil
    private var audioStreamDescription: AudioStreamBasicDescription = AudioStreamBasicDescription()
    private var audioOutputQueue: AudioQueueRef? = nil
    
    init() {

        AudioFileStreamOpen(unsafeBitCast(self, to: UnsafeMutableRawPointer.self),
                            { (inClientData, inAudioFileStream, inPropertyID, ioFlags) in
            if inPropertyID == kAudioFileStreamProperty_DataFormat {
                let mySelf = Unmanaged<StreamAudioPlayer>.fromOpaque(inClientData).takeUnretainedValue()
                
                var dataSize: UInt32 = 0
                var writable: DarwinBoolean = false
                AudioFileStreamGetPropertyInfo(inAudioFileStream, inPropertyID, &dataSize, &writable)
                AudioFileStreamGetProperty(inAudioFileStream, inPropertyID, &dataSize, &mySelf.audioStreamDescription)
                print(dataSize)
                mySelf.createAudioQueue()
            }
        }, { (inClientData, inNumberBytes, inNumberPackets, inInputData, inPacketDescriptions) in
            
        }, kAudioFileMP3Type, &audioFileStreamID)
    }
    
    func readyToPlay() {
        dataSource?.responseData(completedBlock: {[weak self] (data) in
            self?.parse(data: data as NSData)
        })
    }
    
    func play() {
        guard let outputQueue = audioOutputQueue else { return }
        AudioQueueStart(outputQueue, nil)
    }
    
    func pause() {
        guard let outputQueue = audioOutputQueue else { return }
        AudioQueuePause(outputQueue)
    }
    
    deinit {
        if let audioFileStreamID = audioFileStreamID {
            AudioFileStreamClose(audioFileStreamID)
        }
    }
    
    private func createAudioQueue() {
        /// 新建输出队列
        AudioQueueNewOutput(&audioStreamDescription, { (inUserData, inAQ, inBuffer) in
            AudioQueueFreeBuffer(inAQ, inBuffer)
        }, unsafeBitCast(self, to: UnsafeMutableRawPointer.self), CFRunLoopGetCurrent(), nil, 0, &audioOutputQueue)
        
        guard let audioOutputQueue = audioOutputQueue else { return }
        
        AudioQueueAddPropertyListener(audioOutputQueue, kAudioQueueProperty_IsRunning, { (inUserData, inAQ, inID) in
            
        }, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
        
        
        AudioQueuePrime(audioOutputQueue, 0, nil)
        AudioQueueStart(audioOutputQueue, nil)
    }
    
    private func parse(data: NSData) {
        guard let audioFileStreamID = audioFileStreamID else { return }
        AudioFileStreamParseBytes(audioFileStreamID,
                                  UInt32(data.length),
                                  data.bytes,
                                  AudioFileStreamParseFlags(rawValue: 0))
    }
}

//
//func KKAudioFileStreamPacketsCallback(clientData: UnsafeMutablePointer<Void>, numberBytes: UInt32, numberPackets: UInt32, ioData: UnsafePointer<Void>, packetDescription: UnsafeMutablePointer<AudioStreamPacketDescription>) {
//    let this = Unmanaged<KKSimplePlayer>.fromOpaque(COpaquePointer(clientData)).takeUnretainedValue()
//    this.storePackets(numberPackets, numberOfBytes: numberBytes, data: ioData, packetDescription: packetDescription)
//}
//
//func KKAudioQueueOutputCallback(clientData: UnsafeMutablePointer<Void>, AQ: AudioQueueRef, buffer: AudioQueueBufferRef) {
//    let this = Unmanaged<KKSimplePlayer>.fromOpaque(COpaquePointer(clientData)).takeUnretainedValue()
//    AudioQueueFreeBuffer(AQ, buffer)
//    this.enqueueDataWithPacketsCount(Int(this.framePerSecond * 5))
//}
//
//func KKAudioQueueRunningListener(clientData: UnsafeMutablePointer<Void>, AQ: AudioQueueRef, propertyID: AudioQueuePropertyID) {
//    let this = Unmanaged<KKSimplePlayer>.fromOpaque(COpaquePointer(clientData)).takeUnretainedValue()
//    var status: OSStatus = 0
//    var dataSize: UInt32 = 0
//    status = AudioQueueGetPropertySize(AQ, propertyID, &dataSize);
//    assert(noErr == status)
//    if propertyID == kAudioQueueProperty_IsRunning {
//        var running: UInt32 = 0
//        status = AudioQueueGetProperty(AQ, propertyID, &running, &dataSize)
//        this.stopped = running == 0
//    }
//}
