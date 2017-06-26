//
//  ShowStatViewController.swift
//  Stat
//
//  Created by William on 18/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit

class ShowStatViewController: UIViewController {

    // Model
    var game: Game? {
        didSet {
            self.statGenerator = StatGenerator(game: game!)
        }
    }
    var statGenerator: StatGenerator?
    
    // View
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        statGenerator?.genStatPDF(completion: showPDF)
    }

    

    // Function    
    func showPDF() {
        let fm = FileManager.default
        let docsurl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let url = docsurl.appendingPathComponent("/" + statGenerator!.directory + "/stat.pdf")
        
        webView.loadRequest(URLRequest(url: url))
        activityIndicator.stopAnimating()
    }
}
