//
//  ViewController.swift
//  CatalystFullScreenVideo
//
//  Created by Tom Lokhorst on 2020-08-03.
//

import UIKit
import AVKit


let url = URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2020/10056/10/84E5DAD2-E465-453E-86A4-162790B87A16/wwdc2020_10056_hd.mp4?dl=1")!

class ViewController: UIViewController {

    let playervc = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.embed(playervc, insets: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))

        playervc.view.backgroundColor = UIColor.darkGray
        playervc.allowsPictureInPicturePlayback = true
        playervc.delegate = self

        playervc.player = AVPlayer(url: url)
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

}

extension ViewController: AVPlayerViewControllerDelegate {

}
