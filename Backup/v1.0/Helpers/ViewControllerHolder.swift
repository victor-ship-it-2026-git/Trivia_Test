import SwiftUI
import UIKit

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return ViewControllerHolder(value: windowScene.windows.first?.rootViewController)
        }
        return ViewControllerHolder(value: nil)
    }
}

extension EnvironmentValues {
    var viewController: ViewControllerHolder {
        get { return self[ViewControllerKey.self] }
        set { self[ViewControllerKey.self] = newValue }
    }
}
