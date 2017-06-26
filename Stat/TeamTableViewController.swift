//
//  TeamTableViewController.swift
//  Stat
//
//  Created by William on 6/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit
import CoreData

class TeamTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source (UITableViewDataSource)

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
     */

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return teams.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Team", for: indexPath)

        // Configure the cell...
        let team = teams[indexPath.row]
        cell.textLabel?.text = team.name
        cell.textLabel?.font = cell.textLabel?.font.withSize(25.0)

        return cell
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(teams[indexPath.row])
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            loadData()
            
        }    
    }
 
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    }
 

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true 
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let addTeamVC = segue.destination as? AddTeamViewController {
            addTeamVC.teamTableVC = self
        }
        
        if let teamPlayerVC = segue.destination as? TeamPlayerViewController {
            teamPlayerVC.teamName = ((sender as! UITableViewCell).textLabel?.text)!
            teamPlayerVC.team = teams[(tableView.indexPath(for: sender as! UITableViewCell)?.row)!]
            
        }
    }
 

    
    // Our parts
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
