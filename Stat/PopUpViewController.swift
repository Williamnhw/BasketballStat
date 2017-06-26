//
//  PopUpViewController.swift
//  Stat
//
//  Created by William on 12/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    var delegate: PopUpVCDelegate?
    var point: CGPoint?

    @IBAction func bt(_ sender: UIButton) {
        let made = sender.titleLabel?.text == "Made"
        delegate?.recordShoot(point: point!, isMade: made)
        dismiss(animated: false, completion: nil)
    }
    

}

protocol PopUpVCDelegate {
    func recordShoot(point: CGPoint, isMade: Bool)
}
