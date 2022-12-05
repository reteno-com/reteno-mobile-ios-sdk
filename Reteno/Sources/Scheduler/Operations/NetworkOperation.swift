//
//  NetworkOperation.swift
//  
//
//  Created by Serhii Prykhodko on 19.10.2022.
//

import Foundation

class NetworkOperation: Operation {
    
    /// State stored as an enum
    private enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
    }
    
    private var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: state.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
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
            finish()
            
            return
        }
        
        if !isExecuting {
            state = .executing
        }
        main()
    }
    
    /// Move to the finished state
    func finish() {
        guard isExecuting else { return }
        
        state = .finished
    }
    
    /// Cancels the Operation
    override func cancel() {
        super.cancel()
        
        finish()
    }
    
}
