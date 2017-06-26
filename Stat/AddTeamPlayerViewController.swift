//
//  AddTeamPlayerViewController.swift
//  Stat
//
//  Created by William on 7/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit

class AddTeamPlayerViewController: UIViewController, UITextFieldDelegate {
    
    var teamPlayerVC: TeamPlayerViewController?

    @IBOutlet weak var tfNumber: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var btAddPlayer: UIButton!
    
    @IBAction func btCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func btAddPlayer(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        let player = Player(context: managedObjectContext)
        player.name = tfName.text
        player.number = Int16(tfNumber.text!)!
        
        teamPlayerVC?.team?.addToPlayers(player)
        
        // Save to database
        appDelegate.saveContext()
        
        teamPlayerVC?.loadData()
                
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tfNumber.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField==tfNumber) {
            tfName.becomeFirstResponder()
        } else {
            btAddPlayer.sendActions(for: .touchUpInside)
        }
        return true
    }
    

}
