//
//  BaseTask.swift
//  Pods
//
//  Created by Zhixuan Lai on 6/1/16.
//  Converted to Swift 3 by Tom Kroening 4/11/2017
//

import Foundation

public enum Result<ReturnType> {

    case success(ReturnType)
    case failure(Error)

    public func extract() throws -> ReturnType {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
    
}

public protocol ThrowableTaskType {
    associatedtype ReturnType

    func action(_ completion: @escaping  (Result<ReturnType>) -> ())
    func asyncResult(_ queue: AsyncQueue, completion: @escaping (Result<ReturnType>) -> ())
    func awaitResult(_ queue: AsyncQueue) -> Result<ReturnType>
    func await(_ queue: AsyncQueue) throws -> ReturnType
}

extension ThrowableTaskType {

    public func asyncResult(_ queue: AsyncQueue = DefaultQueue, completion: @escaping ((Result<ReturnType>) -> ()) = {_ in}) {
        queue.get().async {
            self.action(completion)
        }
    }

    public func awaitResult(_ queue: AsyncQueue = DefaultQueue) -> Result<ReturnType> {
        let timeout = DispatchTime(timeInterval: TimeoutForever)

        var value: Result<ReturnType>?
        let fd_sema = DispatchSemaphore(value: 0)

        queue.get().async {
            self.action {result in
                value = result
                fd_sema.signal()
            }
        }

        _ = fd_sema.wait(timeout: timeout)

        return value!
    }

    public func await(_ queue: AsyncQueue = DefaultQueue) throws -> ReturnType {
        return try awaitResult(queue).extract()
    }

}

open class ThrowableTask<ReturnType> : ThrowableTaskType {

    open let action: (@escaping ( Result<ReturnType>) -> ()) -> ()

    open func action(_ completion: @escaping (Result<ReturnType>) -> ()) {
        action(completion)
    }

    public init(action anAction: @escaping ( @escaping (Result<ReturnType>) -> ()) -> ()) {
        action = anAction
    }

    public convenience init(action: @escaping () -> Result<ReturnType>) {
        self.init {callback in callback(action())}
    }

    public convenience init(action: @escaping ((ReturnType) -> ()) throws -> ()) {
        self.init {(callback: (Result<ReturnType>) -> ()) in
            do {
                try action {result in
                    callback(Result.success(result))
                }
            } catch {
                callback(Result.failure(error))
            }
        }
    }

    public convenience init(action: @escaping () throws -> ReturnType) {
        self.init {(callback: (Result<ReturnType>) -> ()) in
            do {
                callback(Result.success(try action()))
            } catch {
                callback(Result.failure(error))
            }
        }
    }

}
