//
//  Wait.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/27/16.
//  Converted to Swift 3 by Tom Kroening 4/11/2017
//

import Foundation

extension Sequence where Iterator.Element : ThrowableTaskType {

    public func awaitFirstResult(_ queue: AsyncQueue = DefaultQueue) -> Result<Iterator.Element.ReturnType> {
        let tasks = map{$0}
        return Task {
            (callback:  @escaping (Result<Iterator.Element.ReturnType>) -> ())
            in
            tasks.concurrentForEach(queue, transform: {task in task.awaitResult()}) { index, result in
                callback(result)
            }
        }.await(queue)
    }

    public func awaitAllResults(_ queue: AsyncQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Result<Iterator.Element.ReturnType>] {
        let tasks = map{$0}
        return tasks.concurrentMap(queue, concurrency: concurrency) {task in task.awaitResult()}
    }

    public func awaitFirst(_ queue: AsyncQueue = DefaultQueue) throws -> Iterator.Element.ReturnType {
        return try awaitFirstResult(queue).extract()
    }

    public func awaitAll(_ queue: AsyncQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Iterator.Element.ReturnType] {
        return try awaitAllResults(queue, concurrency: concurrency).map {try $0.extract()}
    }

}

extension Dictionary where Value : ThrowableTaskType {

    public func awaitFirst(_ queue: AsyncQueue = DefaultQueue) throws -> Value.ReturnType {
        return try values.awaitFirst(queue)
    }

    public func awaitAll(_ queue: AsyncQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Key: Value.ReturnType] {
        let elements = Array(zip(Array(keys), try values.awaitAll(queue, concurrency: concurrency)))
        return Dictionary<Key, Value.ReturnType>(elements: elements)
    }
    
}

extension Sequence where Iterator.Element : TaskType {

    var throwableTasks: [ThrowableTask<Iterator.Element.ReturnType>] {
        return map {$0.throwableTask}
    }

    public func awaitFirst(_ queue: AsyncQueue = DefaultQueue) -> Iterator.Element.ReturnType {
        return try! throwableTasks.awaitFirstResult(queue).extract()
    }

    public func awaitAll(_ queue: AsyncQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Iterator.Element.ReturnType] {
        return throwableTasks.awaitAllResults(queue, concurrency: concurrency).map {result in try! result.extract() }
    }

}

extension Dictionary where Value : TaskType {

    var throwableTasks: [ThrowableTask<Value.ReturnType>] {
        return values.throwableTasks
    }

    public func awaitFirst(_ queue: AsyncQueue = DefaultQueue) -> Value.ReturnType {
        return try! throwableTasks.awaitFirstResult(queue).extract()
    }

    public func await(_ queue: AsyncQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Key: Value.ReturnType] {
        let elements = Array(zip(Array(keys), try! throwableTasks.awaitAll(queue, concurrency: concurrency)))
        return Dictionary<Key, Value.ReturnType>(elements: elements)
    }

}

extension Dictionary {

    init(elements: [(Key, Value)]) {
        self.init()
        for (key, value) in elements {
            updateValue(value, forKey: key)
        }
    }

}

extension Array {

    func concurrentForEach<U>(_ queue: AsyncQueue, transform: @escaping (Element) -> U, completion: @escaping (Int, U) -> ()) {
        let fd_sema = DispatchSemaphore(value: 0)

        var numberOfCompletedTasks = 0
        let numberOfTasks = count

        for (index, item) in enumerated() {
            queue.get().async {
                let result = transform(item)
                AsyncQueue.getCollectionQueue().get().sync {
                    completion(index, result)
                    numberOfCompletedTasks += 1
                    if numberOfCompletedTasks == numberOfTasks {
                        fd_sema.signal()
                    }
                }
            }
        }

        _ = fd_sema.wait(timeout: DispatchTime(timeInterval: -1))
    }

    func concurrentMap<U>(_ queue: AsyncQueue, concurrency: Int, transform: @escaping (Element) -> U) -> [U] {
        let fd_sema = DispatchSemaphore(value: 0)
        let fd_sema2 = DispatchSemaphore(value: concurrency)

        var results = [U?](repeating: nil, count: count)
        var numberOfCompletedTasks = 0
        let numberOfTasks = count

        DispatchQueue.concurrentPerform(iterations: count) {index in
            _ = fd_sema2.wait(timeout: DispatchTime(timeInterval: -1))
            let result = transform(self[index])
            AsyncQueue.getCollectionQueue().get().sync {
                results[index] = result
                numberOfCompletedTasks += 1
                if numberOfCompletedTasks == numberOfTasks {
                    fd_sema.signal()
                }
                fd_sema2.signal()
            }
        }

        _ = fd_sema.wait(timeout: DispatchTime(timeInterval: -1))
        return results.flatMap {$0}
    }

}

