//
//  NewGameTableViewController.swift
//  Stat
//
//  Created by William on 7/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit

class NewGameTableViewController: UITableViewController {
    
    // Model
    var gameTableVC: GameTableViewController?
    
    var homeTeam: Team? {
        didSet {
            lbHomeTeam.text = homeTeam?.name
        }
    }
    
    var guestTeam: Team? {
        didSet {
            lbGuestTeam.text = guestTeam?.name
        }
    }
    
    var date: Date? {
        didSet {
            lbDateTime.text = DateFormatter.localizedString(from: self.date!, dateStyle: .short, timeStyle: .short)
        }
    }
    
    var teamVersus: String?
    var venue: String?

    
    // View
    @IBOutlet weak var lbHomeTeam: UILabel!
    @IBOutlet weak var lbGuestTeam: UILabel!
    
    
    @IBAction func btCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var tfTeamVersus: UITextField!
    @IBOutlet weak var cellDate: UITableViewCell!
    @IBOutlet weak var lbDateTime: UILabel!
    @IBOutlet weak var cellDatePicker: UITableViewCell!
    @IBAction func datePickerChange(_ sender: UIDatePicker) {self.date = sender.date}
    @IBOutlet weak var tfVenue: UITextField!
    
    @IBAction func btDone(_ sender: UIBarButtonItem) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        // Add new Game
        let game = Game(context: managedObjectContext)
        game.homeTeam = homeTeam
        game.guestTeam = guestTeam
        game.time = date as NSDate?
        game.venue = tfVenue.text
        
        // Add new GameStat
        if let players = homeTeam?.players?.allObjects as? [Player] {
            for player in players {
                let gameStat = GameStat(context: managedObjectContext)
                player.addToGamesStat(gameStat)
                game.addToHomeTeamPlayersStat(gameStat)
            }
        }
        
        if let players = guestTeam?.players?.allObjects as? [Player] {
            for player in players {
                let gameStat = GameStat(context: managedObjectContext)
                player.addToGamesStat(gameStat)
                game.addToGuestTeamPlayerStat(gameStat)
            }
        }
        
        // Add new GameScore
        for isHome in [true,false] {
            for quarter in [1,2,3,4,5] {
                let gameScore = GameScore(context: managedObjectContext)
                gameScore.quarter = Int16(quarter)
                gameScore.score = 0
                if isHome {
                    game.addToHomeTeamScore(gameScore)
                } else {
                    game.addToGuestTeamScore(gameScore)
                }
            }
        }
        
        // Save to database
        appDelegate.saveContext()
        
        gameTableVC?.loadData()
        
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        date = Date()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameTableVC?.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath) == cellDate {
            cellDatePicker.isHidden = !self.cellDatePicker.isHidden
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let gameTeamTableVC = segue.destination as? NewGameTeamTableViewController {
            gameTeamTableVC.newGameTableVC = self
            gameTeamTableVC.isHomeTeam = tableView.indexPath(for: sender as! UITableViewCell)?.row == 0
        }
    }
 

    
    
}
