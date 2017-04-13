//
//  Misc.swift
//  AsyncDemo
//
//  Created by Zhixuan Lai on 2/26/16.
//  Copyright © 2016 Zhixuan Lai. All rights reserved.
//  Converted to Swift 3 by Tom Kroening 4/11/2017

import Foundation

// https://developer.apple.com/library/ios/documentation/Performance/Conceptual/EnergyGuide-iOS/PrioritizeWorkWithQoS.html#//apple_ref/doc/uid/TP40015243-CH39-SW39
@available(iOS 8.0, OSX 10.10, *)
public enum AsyncQueue {

    case main
    case userInteractive    // Work is virtually instantaneous.
    case userInitiated      // Work is nearly instantaneous, such as a few seconds or less.
    case utility            // Work takes a few seconds to a few minutes.
    case background         // Work takes significant time, such as minutes or hours.
    case custom(Dispatch.DispatchQueue)

    public func get() -> DispatchQueue {
        switch self {
        case .main:
            return DispatchQueue.main
        case .userInteractive:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
        case .userInitiated:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        case .utility:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
        case .background:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        case .custom(let queue):
            return queue
        }
    }

    static public func getCollectionQueue() -> AsyncQueue {
        return .custom(q)
    }

}

let q = DispatchQueue(label: "com.asynctask.serial.queue", attributes: []);
