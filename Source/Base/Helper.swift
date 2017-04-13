//
//  Misc.swift
//  Pods
//
//  Created by Zhixuan Lai on 3/1/16.
//  Converted to Swift 3 by Tom Kroening 4/11/2017
//

import Foundation

internal extension DispatchTime {
    init(timeInterval: TimeInterval) {
        

        let timeVal = timeInterval < TimeInterval(0) ? DispatchTime.distantFuture : DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        self.init(uptimeNanoseconds: timeVal.uptimeNanoseconds)
    }
}
