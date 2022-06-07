//
//  Thread.swift
//
//  Created by Lazar Sidor on 27.05.2022.
//

import Foundation

extension Thread {
    public static func performOnMain(_ executionClosure: () -> Void) {
        guard Thread.isMainThread
        else {
            DispatchQueue.main.sync {
                executionClosure()
            }
            return
        }
        executionClosure()
    }
}
