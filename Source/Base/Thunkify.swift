//
//  Thunkify.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/27/16.
//  Converted to Swift 3 by Tom Kroening 4/11/2017
//

import Foundation

public func thunkify<A, T>(_ function: @escaping (A, (T) -> Void) -> Void) -> ((A) -> Task<T>) {
    return {a in Task<T> {callback in function(a, callback) } }
}

public func thunkify<A, B, T>(_ function: @escaping (A, B, (T) -> Void) -> Void) -> ((A, B) -> Task<T>) {
    return {a, b in Task<T> {callback in function(a, b, callback) } }
}

public func thunkify<A, B, C, T>(_ function: @escaping (A, B, C, (T) -> ()) -> ()) -> ((A, B, C) -> Task<T>) {
    return {a, b, c in Task<T> {callback in function(a, b, c, callback) } }
}

public func thunkify<A, B, C, D, T>(_ function: @escaping (A, B, C, D, (T) -> ()) -> ()) -> ((A, B, C, D) -> Task<T>) {
    return {a, b, c, d in Task<T> {callback in function(a, b, c, d, callback) } }
}
