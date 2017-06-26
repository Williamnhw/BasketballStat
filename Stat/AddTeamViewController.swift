//
//  AddTeamViewController.swift
//  Stat
//
//  Created by William on 6/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit

class AddTeamViewController: UIViewController {
    
    var teamTableVC: TeamTableViewController?

    @IBOutlet weak var tfName: UITextField!
    
    @IBAction func btAddTeam(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        let team = Team(context: managedObjectContext)
        team.name = tfName.text!
        
        // Save to database
        appDelegate.saveContext()
        
        teamTableVC?.loadData()
        
        dismiss(animated: true)
    }
    
    @IBAction func btCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
