// Free to use

import UIKit

class ViewController: UIViewController {

    let button1 = CustomEdgeInsetsHitTestButton(type: .system)
    let button2 = CustomEdgeInsetsHitTestButton(type: .system)
    let stackView = CustomEdgeInsetsHitTestStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        button1.setTitle("Tap me", for: .normal)
        button1.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        button2.setTitle("Tap me", for: .normal)
        button2.titleLabel?.font = .preferredFont(forTextStyle: .title3)

        button1.addDefaultPointerInteraction()
        button2.addDefaultPointerInteraction()

        stackView.axis = .horizontal
        let buttonSpacing = -(button1.hitTestEdgeInset?.left ?? CustomEdgeInsetsHitTestButton.defaultHitTestEdgeInset.left)
        stackView.spacing = buttonSpacing * 2
        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(button2)
        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

final class CustomEdgeInsetsHitTestButton: UIButton {

    static let defaultHitTestEdgeInset = UIEdgeInsets.all(-20)
    var hitTestEdgeInset: UIEdgeInsets?

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.inset(by: hitTestEdgeInset ?? Self.defaultHitTestEdgeInset).contains(point)
    }

    func addDefaultPointerInteraction() {
        addInteraction(UIPointerInteraction(delegate: self))
    }
}

extension CustomEdgeInsetsHitTestButton: UIPointerInteractionDelegate {

    func pointerInteraction(_ interaction: UIPointerInteraction, regionFor request: UIPointerRegionRequest, defaultRegion: UIPointerRegion) -> UIPointerRegion? {
        UIPointerRegion(
            rect: defaultRegion.rect.inset(
                by: hitTestEdgeInset ?? CustomEdgeInsetsHitTestButton.defaultHitTestEdgeInset
            )
        )
    }

    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        guard let view = interaction.view else { return nil }

        let preview = UITargetedPreview(view: view)
        let rect = view.frame.insetBy(dx: -12, dy: -10)

        return UIPointerStyle(effect: .highlight(preview), shape: .roundedRect(rect))
    }
}

final class CustomEdgeInsetsHitTestStackView: UIStackView {

    static let defaultHitTestEdgeInset = UIEdgeInsets.all(-20)
    var hitTestEdgeInset: UIEdgeInsets?

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.inset(by: hitTestEdgeInset ?? Self.defaultHitTestEdgeInset).contains(point)
    }
}
