//
//  GameTeamTableViewController.swift
//  Stat
//
//  Created by William on 7/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit

class NewGameTeamTableViewController: UITableViewController {
    
    var newGameTableVC: NewGameTableViewController?
    var isHomeTeam: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return teams.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameTeam", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = teams[indexPath.row].name
        
        let tempTeam: Team?
        if isHomeTeam! {
            tempTeam = newGameTableVC?.homeTeam
        } else {
            tempTeam = newGameTableVC?.guestTeam
        }

        
        if let team = tempTeam, team == teams[indexPath.row] {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isHomeTeam! {
            newGameTableVC?.homeTeam = teams[indexPath.row]
        } else {
            newGameTableVC?.guestTeam = teams[indexPath.row]
        }
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    // Model
    var teams: [Team] = []

    func loadData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            teams = try context.fetch(Team.fetchRequest())
            tableView.reloadData()
        }
        catch {
            print("Fetching Failed")
        }
    }


}
