//
//  ViewControllerHolder.swift
//  Trivia_Test
//
//  Created by Win on 8/10/2568 BE.
//


//
//  ViewControllerHolder.swift
//  Trivia_Test
//
//  Created by Win
//

import SwiftUI
import UIKit

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)
    }
}

extension EnvironmentValues {
    var viewController: ViewControllerHolder {
        get { return self[ViewControllerKey.self] }
        set { self[ViewControllerKey.self] = newValue }
    }
}