//
//  TeamPlayerViewController.swift
//  Stat
//
//  Created by William on 6/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit
import CoreData

class TeamPlayerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfTeamName: UITextField!
    
    @IBOutlet weak var btTableEdit: UIBarButtonItem!
    
    
    func btEditChange() {
        if (tableView.isEditing) {
            tableView.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItems?[1] = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(TeamPlayerViewController.btEditChange))
        } else {
            tableView.setEditing(true, animated: true)
            self.navigationItem.rightBarButtonItems?[1] = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(TeamPlayerViewController.btEditChange))
        }
    }
    
    @IBAction func btChangeTeamName(_ sender: UIButton) {
        team?.name = tfTeamName.text
        do {try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save()}
        catch {}
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tfTeamName.text = teamName
        loadData()
        
        self.navigationItem.rightBarButtonItems?[1] = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(TeamPlayerViewController.btEditChange))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITableViewDataSource, UITableViewDelegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Player", for: indexPath) as! TeamPlayerTableViewCell

        let player = players[indexPath.row]
        cell.lbName.text = player.name
        cell.lbNumber.text = "\(player.number)"
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(players[indexPath.row])
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            loadData()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addTeamPlayerVC = segue.destination as? AddTeamPlayerViewController {
            addTeamPlayerVC.teamPlayerVC = self
        }
    }
    
    var players: [Player] = []
    var selectedPlayer: Int?
    var teamName = ""
    var team: Team?
    
    func loadData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {            let fetchRequest:NSFetchRequest<Player> = Player.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "team == %@", team!)
            players = try context.fetch(fetchRequest)
            tableView.reloadData()
        }
        catch {
            print("Fetching Failed")
        }
        tableView.reloadData()
    }

    
}
