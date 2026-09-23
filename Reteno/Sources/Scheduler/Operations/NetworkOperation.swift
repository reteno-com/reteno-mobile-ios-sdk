//
//  NetworkOperation.swift
//  
//
//  Created by Serhii Prykhodko on 19.10.2022.
//

import Foundation

class NetworkOperation: Operation, @unchecked Sendable {
    
    /// State stored as an enum
    private enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
    }
    
    private let stateLock = NSLock()
    /// Backing storage for `state`, only ever touched while holding `stateLock`
    private var lockedState = State.ready
    
    private var state: State {
        stateLock.lock()
        defer { stateLock.unlock() }
        
        return lockedState
    }
    
    override var isReady: Bool {
        super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        state == .executing
    }
    
    override var isFinished: Bool {
        state == .finished
    }
    
    /// Start the Operation
    override func start() {
        guard !isCancelled else {
            setState(.finished, from: [.ready, .executing])

            return
        }

        setState(.executing, from: [.ready])
        main()
    }

    /// Move to the finished state
    func finish() {
        setState(.finished, from: [.executing])
    }
    
    /// Atomically moves the operation to `newState`, ignoring the call when it is no longer in one
    /// of `allowedStates`.
    ///
    /// `OperationQueue` reads `isReady`/`isExecuting`/`isFinished` from its own threads while
    /// network callbacks drive the transitions from another one, so the compare-and-swap has to
    /// happen under a lock. Without it `finish()` could read a stale `.ready` and silently drop
    /// the transition, leaving the operation executing forever and blocking the serial queue.
    private func setState(_ newState: State, from allowedStates: Set<State>) {
        stateLock.lock()
        let oldState = lockedState
        guard allowedStates.contains(oldState), oldState != newState else {
            stateLock.unlock()
            
            return
        }
        lockedState = newState
        stateLock.unlock()
        
        /// KVO is posted outside of the lock so that an observer can never re-enter it
        willChangeValue(forKey: newState.rawValue)
        willChangeValue(forKey: oldState.rawValue)
        didChangeValue(forKey: oldState.rawValue)
        didChangeValue(forKey: newState.rawValue)
    }
    
}
