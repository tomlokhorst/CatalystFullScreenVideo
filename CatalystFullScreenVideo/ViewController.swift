//
//  ViewController.swift
//  CatalystFullScreenVideo
//
//  Created by Tom Lokhorst on 2020-08-03.
//

import UIKit
import AVKit
import Dynamic


let url = URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2020/10056/10/84E5DAD2-E465-453E-86A4-162790B87A16/wwdc2020_10056_hd.mp4?dl=1")!

extension NSNotification.Name {

    static var NSWindowWillEnterFullScreenNotification: NSNotification.Name {
        NSNotification.Name("NSWindowWillEnterFullScreenNotification")
    }

    static var NSWindowDidEnterFullScreenNotification: NSNotification.Name {
        NSNotification.Name("NSWindowDidEnterFullScreenNotification")
    }

    static var NSWindowWillExitFullScreenNotification: NSNotification.Name {
        NSNotification.Name("NSWindowWillExitFullScreenNotification")
    }

    static var NSWindowDidExitFullScreenNotification: NSNotification.Name {
        NSNotification.Name("NSWindowDidExitFullScreenNotification")
    }
}

class ViewController: UIViewController {

    let playervc = AVPlayerViewController()
    var playerIsFullScreen = false
    var playerIsEnteringFullScreen = false
    var playerIsExitingFullScreen = false
    var windowIsEnteringFullScreen = false
    var windowIsExitingFullScreen = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.embed(playervc, insets: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))

        playervc.view.backgroundColor = UIColor.darkGray
        playervc.allowsPictureInPicturePlayback = true
        playervc.delegate = self

        playervc.player = AVPlayer(url: url)

        NotificationCenter.default
            .addObserver(self, selector: #selector(windowWillEnterFullScreen), name: .NSWindowWillEnterFullScreenNotification, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(windowDidEnterFullScreen), name: .NSWindowDidEnterFullScreenNotification, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(windowWillExitFullScreen), name: .NSWindowWillExitFullScreenNotification, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(windowDidExitFullScreen), name: .NSWindowDidExitFullScreenNotification, object: nil)
    }

    func embed(_ viewController: UIViewController, insets: UIEdgeInsets) {
        viewController.willMove(toParent: self)
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: viewController.view.topAnchor, constant: -insets.top),
            view.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor, constant: insets.bottom),
            view.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: -insets.left),
            view.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: insets.right),
        ])
        viewController.didMove(toParent: self)
    }

    override var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(input: "f", modifierFlags: [], action: #selector(triggerFullScreen(_:))),
        ]
    }

    @objc func triggerFullScreen(_ sender: Any?) {
        if !playerIsEnteringFullScreen {
            playervc.transitionToFullScreen(animated: true)
        }
    }

    @objc func windowWillEnterFullScreen() {
        windowIsEnteringFullScreen = true

        if !playerIsEnteringFullScreen {
            playervc.transitionToFullScreen(animated: false)
        }
    }

    @objc func windowDidEnterFullScreen() {
        windowIsEnteringFullScreen = false
    }

    @objc func windowWillExitFullScreen() {
        windowIsExitingFullScreen = true

        if !playerIsExitingFullScreen {
            playervc.transitionFromFullScreen(animated: false)
        }
    }

    @objc func windowDidExitFullScreen() {
        windowIsExitingFullScreen = false
    }
}

extension UIWindow {
    var nsWindow: NSObject? {
        Dynamic.NSApplication.sharedApplication.delegate.hostWindowForUIWindow(self)
    }

    var isFullScreen: Bool? {
        guard let nsWindow = nsWindow else { return nil }
        let styleMask = Dynamic(nsWindow).styleMask.asUInt ?? 0

        let NSWindowStyleMaskFullScreen: UInt = 1 << 14
        let masked = styleMask & NSWindowStyleMaskFullScreen

        return masked == NSWindowStyleMaskFullScreen
    }
}

extension ViewController: AVPlayerViewControllerDelegate {

    func windowToggleFullScreen() {
        if let nsWindow = view.window?.nsWindow {
            Dynamic(nsWindow).toggleFullScreen(nil)
        }
    }

    var windowIsFullScreen: Bool? {
        view.window?.isFullScreen
    }

    func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        // Called when player is transitioning to full screen (from user click, or code)
        coordinator.animate { (context) in

            self.playerIsEnteringFullScreen = true

            if let windowIsFullScreen = self.windowIsFullScreen,
               !windowIsFullScreen && !self.windowIsEnteringFullScreen {
                self.windowToggleFullScreen()
            }

        } completion: { (context) in
            self.playerIsFullScreen = true
            self.playerIsEnteringFullScreen = false
        }

    }

    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        // Called when player is transitioning out of full screen
        // Note, only called from user click, not when triggered from code
        coordinator.animate { (context) in

            self.playerIsExitingFullScreen = true

            if let windowIsFullScreen = self.windowIsFullScreen,
               windowIsFullScreen && !self.windowIsExitingFullScreen {
                self.windowToggleFullScreen()
            }

        } completion: { (context) in
            self.playerIsFullScreen = false
            self.playerIsExitingFullScreen = false
        }

    }
}

extension AVLayerVideoGravity {
    var description: String {
        switch self {
        case .resize: return "resize"
        case .resizeAspect: return "resizeAspect"
        case .resizeAspectFill: return "resizeAspectFill"
        default:
            assertionFailure()
            return "unknown"
        }
    }
}

extension AVPlayerViewController {

    func transitionToFullScreen(animated: Bool) {
        Dynamic(self)._transitionToFullScreenAnimated(animated, interactive: nil, completionHandler: nil)
    }

    func transitionFromFullScreen(animated: Bool) {
        Dynamic(self)._transitionFromFullScreenAnimated(animated, interactive: nil, completionHandler: nil)
    }
}
