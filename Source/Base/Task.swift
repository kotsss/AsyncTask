//
//  AsyncTask.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/27/16.
//  Converted to Swift 3 by Tom Kroening 4/11/2017
//

import Foundation

public protocol TaskType {
    associatedtype ReturnType

    func action(_ completion: @escaping ( ReturnType) -> ())
    func async(_ queue: AsyncQueue, completion: @escaping (ReturnType) -> ())
    func await(_ queue: AsyncQueue) -> ReturnType
}

extension TaskType {

    public var throwableTask: ThrowableTask<ReturnType> {
        return ThrowableTask<ReturnType>{callback in
            self.action {result in
                callback(Result.success(result))
            }
        }
    }

    public func async(_ queue: AsyncQueue = DefaultQueue, completion: @escaping ((ReturnType) -> ()) = {_ in}) {
        throwableTask.asyncResult(queue) {result in
            if case let .success(r) = result {
                completion(r)
            }
        }
    }

    public func await(_ queue: AsyncQueue = DefaultQueue) -> ReturnType {
        return try! throwableTask.awaitResult(queue).extract()
    }

}

open class Task<ReturnType> : TaskType {

    open let action: (@escaping (ReturnType) -> ()) -> ()

    open func action(_ completion: @escaping (ReturnType) -> ()) {
        action(completion)
    }

    public init(action anAction:  @escaping ( @escaping (ReturnType) -> ()) -> ()) {
        action = anAction
    }

    public convenience init(action anAction: @escaping () -> ReturnType) {
        self.init {callback in callback(anAction())}
    }

}
