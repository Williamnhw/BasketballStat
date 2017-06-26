//
//  GameTableViewController.swift
//  Stat
//
//  Created by William on 7/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit

class GameTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return games.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Game", for: indexPath)

        // Configure the cell...
        let label = (games[indexPath.row].homeTeam?.name)! + " : " + (games[indexPath.row].guestTeam?.name)!
        cell.textLabel?.text = label

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(games[indexPath.row])
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            loadData()
            
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let newGameTableVC = segue.destination.childViewControllers.first as? NewGameTableViewController {
            newGameTableVC.gameTableVC = self
        }
        
        if let gameStatVC = segue.destination as? GameStatViewController {
            gameStatVC.game = games[(tableView.indexPath(for: (sender as! UITableViewCell))?.row)!]
        }
    }
 
    
    // Model
    var games: [Game] = []
    
    func loadData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            games = try context.fetch(Game.fetchRequest())
            games.sort(by: {($0.homeTeam?.name)! < ($1.homeTeam?.name)!})
            tableView.reloadData()
        }
        catch {
            print("Fetching Failed")
        }
    }
    

}
