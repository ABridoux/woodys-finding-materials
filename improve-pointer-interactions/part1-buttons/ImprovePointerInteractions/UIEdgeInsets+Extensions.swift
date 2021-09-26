// Free to use

import UIKit

extension UIEdgeInsets {

    static func all(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }
}
