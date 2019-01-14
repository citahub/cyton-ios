//
//  TaskThread.swift
//  Cyton
//
//  Created by 晨风 on 2018/12/11.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class TaskThread: NSObject {
    typealias Block = () -> Void
    private(set) var thread: Thread?

    func perform(_ block: @escaping Block) {
        guard let thread = thread else { return }
        let task = Task(block: block)
        let sel = #selector(TaskThread.taskHandler(task:))
        perform(sel, on: thread, with: task, waitUntilDone: false)
    }

    func syncPerform(_ block: @escaping Block) {
        guard let thread = thread else { return }
        let task = Task(block: block)
        let sel = #selector(TaskThread.taskHandler(task:))
        perform(sel, on: thread, with: task, waitUntilDone: true)
    }

    @objc func run() {
        guard thread == nil else { return }
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "")
        group.enter()
        queue.async {
            self.thread = Thread.current
            self.runLoop = RunLoop.current
            Thread.current.name = String(describing: TaskThread.self)
            RunLoop.current.add(NSMachPort(), forMode: .default)
            group.leave()
            CFRunLoopRun()
        }
        group.wait()
    }

    @objc func stop() {
        guard thread != nil else { return }
        thread = nil
        if let runloop = runLoop?.getCFRunLoop() {
            CFRunLoopStop(runloop)
        }
    }

    private var runLoop: RunLoop?
    private class Task: NSObject {
        let block: Block
        init(block: @escaping Block) {
            self.block = block
        }
    }

    @objc private func taskHandler(task: Task) {
        task.block()
    }
}
