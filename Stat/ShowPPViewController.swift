//
//  ShowPPViewController.swift
//  Stat
//
//  Created by William on 20/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit

class ShowPPViewController: UIViewController {
    
    // Model
    var game: Game? {
        didSet {
            self.ppGenerator = PPGenerator(game: game!)
        }
    }
    var ppGenerator: PPGenerator?
    var quarter = 1;
    
    // View
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ppGenerator?.genPP(completion: showPDF)
    }

    // Function
    func showPDF() {
        let fm = FileManager.default
        let docsurl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let url = docsurl.appendingPathComponent("/" + ppGenerator!.directory + "/pp" + "\(quarter)" + ".pdf")
        
        webView.loadRequest(URLRequest(url: url))
        activityIndicator.stopAnimating()
    }
}
