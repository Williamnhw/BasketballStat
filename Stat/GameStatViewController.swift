//
//  GameStat2ViewController.swift
//  Stat
//
//  Created by William on 12/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit

class GameStatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PopUpVCDelegate  {
    
    // ---------- Model ----------
    var game: Game? {
        didSet {
            gamePlayers = GamePlayers(game: game!, appDelegate: (UIApplication.shared.delegate as! AppDelegate))
        }
    }
    
    var gamePlayers: GamePlayers?
    
    lazy var homeTeamPlayers: [[Int]] = [
        Array(self.gamePlayers!.homeTeamPlayers.keys.sorted().prefix(5)),    // Section 0: On Court
        Array(self.gamePlayers!.homeTeamPlayers.keys.sorted().dropFirst(5)) ]  // Section 1: Bench
    lazy var guestTeamPlayers: [[Int]] = [
        Array(self.gamePlayers!.guestTeamPlayers.keys.sorted().prefix(5)),    // Section 0: On Court
        Array(self.gamePlayers!.guestTeamPlayers.keys.sorted().dropFirst(5)) ]  // Section 1: Bench  
    
    var quarter = 1
    var homeSub = false
    var guestSub = false
    
    var selectedPlayer: (isHome:Bool,Int)? {
        didSet {
            updateUI()
        }
    }
    var selectedIndexPath: IndexPath?
    
    var remove = false
    
    // Timer:
    let time = 600
    lazy var seconds: Int = self.time
    var timer = Timer()
    var isTimerRunning = false
    var isPaused = false

    
    // ---------- View ----------
    @IBOutlet weak var viewAnchor: UIView!
    
    @IBOutlet weak var segmentQuarter: UISegmentedControl!
    
    @IBOutlet weak var lbHomeTeam: UILabel!
    @IBOutlet weak var tfHomeScore1: UITextField!
    @IBOutlet weak var tfHomeScore2: UITextField!
    @IBOutlet weak var tfHomeScore3: UITextField!
    @IBOutlet weak var tfHomeScore4: UITextField!
    @IBOutlet weak var tfHomeScoreOT: UITextField!
    @IBOutlet weak var lbHomeTeamScore: UILabel!
    
    @IBOutlet weak var lbGuestTeam: UILabel!
    @IBOutlet weak var tfGuestScore1: UITextField!
    @IBOutlet weak var tfGuestScore2: UITextField!
    @IBOutlet weak var tfGuestScore3: UITextField!
    @IBOutlet weak var tfGuestScore4: UITextField!
    @IBOutlet weak var tfGuestScoreOT: UITextField!
    @IBOutlet weak var lbGuestTeamScore: UILabel!
    
    @IBOutlet weak var btRemove: UIButton!
    @IBOutlet weak var lbTimer: UILabel!
    @IBOutlet weak var btStart: UIButton!
    @IBOutlet weak var btStop: UIButton!
    
    
    // UITableView
    @IBOutlet weak var tableViewHome: UITableView!
    @IBOutlet weak var tableViewGuest: UITableView!
    
    // Player Info & Stat
    @IBOutlet weak var lbPlayerTeam: UILabel!
    @IBOutlet weak var lbPlayerNumber: UILabel!
    @IBOutlet weak var lbPlayerName: UILabel!
    @IBOutlet weak var lbPlayerScore: UILabel!
    
    @IBOutlet weak var imageCourt: UIImageView!
    
    // Player Stat
    @IBOutlet weak var stepperMinute: UIStepper!
    @IBOutlet weak var stepperSecond: UIStepper!
    @IBOutlet weak var lbMinutes: UILabel!
    @IBOutlet weak var lbTwoPts: UILabel!
    @IBOutlet weak var lbThreePts: UILabel!
    @IBOutlet weak var lbFT: UILabel!
    @IBOutlet weak var lbDR: UILabel!
    @IBOutlet weak var lbOR: UILabel!
    @IBOutlet weak var lbAST: UILabel!
    @IBOutlet weak var lbSTL: UILabel!
    @IBOutlet weak var lbBS: UILabel!
    @IBOutlet weak var lbTO: UILabel!
    @IBOutlet weak var lbPF: UILabel!
    @IBOutlet weak var lbFD: UILabel!
    
    var shootingViews: [ShootingView] = []
    
    
    // ---------- View Life Cycle ----------
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lbTimer.text = secondToString(time)
        segmentQuarter.selectedSegmentIndex = gamePlayers!.quarter - 1
        updateUI()

    }

    override func viewWillDisappear(_ animated: Bool) {
        if (isTimerRunning && !isPaused) { btStart.sendActions(for: .touchUpInside) }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {        
        drawShootingViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    // Orientation
    override var traitCollection: UITraitCollection {
        if UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isPortrait {
            return UITraitCollection(traitsFrom: [UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    // Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let popUpVC = segue.destination as? PopUpViewController {
            popUpVC.delegate = self
            popUpVC.point = (sender as! UITapGestureRecognizer).location(in: imageCourt)
        }
        if let showStatVC = segue.destination as? ShowStatViewController {
            showStatVC.game = game
        }
        if let showPPVC = segue.destination as? ShowPPViewController {
            showPPVC.game = game
        }
    }
    
    // Table View Data Source, Delegate
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableView==tableViewHome) ? homeTeamPlayers[section].count : guestTeamPlayers[section].count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "On Court"
        case 1:
            return "Bench"
        default:
            return ""
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView==tableViewHome) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Home Team Player Cell", for: indexPath) as! GameStatHomeTableViewCell
            let playerNumber = homeTeamPlayers[indexPath.section][indexPath.row]
            cell.lbNumber.text = String(playerNumber)
            cell.lbName.text = gamePlayers?.getName(player: playerNumber, isHome: true)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Guest Team Player Cell", for: indexPath) as! GameStatGuestTableViewCell
            let playerNumber = guestTeamPlayers[indexPath.section][indexPath.row]
            cell.lbNumber.text = String(playerNumber)
            cell.lbName.text = gamePlayers?.getName(player: playerNumber, isHome: false)
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (playerIsHome,playerNumber) = ((tableView==tableViewHome),(tableView==tableViewHome ? homeTeamPlayers : guestTeamPlayers)[indexPath.section][indexPath.row])
        
        if let (selectedIsHome, selectedPlayerNumber) = self.selectedPlayer {
            if (selectedIsHome==playerIsHome) {
                if (selectedPlayerNumber == playerNumber) {
                    // select the same player -> clear
                    tableView.deselectRow(at: indexPath, animated: false)
                    self.selectedPlayer = nil
                    self.selectedIndexPath = nil
                }
                else if (selectedIsHome ? homeSub : guestSub) {
                    // selected team is on subsutition
                    if (selectedIsHome) {
                        homeTeamPlayers[indexPath.section][indexPath.row] = selectedPlayerNumber
                        homeTeamPlayers[(self.selectedIndexPath?.section)!][(self.selectedIndexPath?.row)!] = playerNumber
                    } else {
                        guestTeamPlayers[indexPath.section][indexPath.row] = selectedPlayerNumber
                        guestTeamPlayers[(self.selectedIndexPath?.section)!][(self.selectedIndexPath?.row)!] = playerNumber
                    }
                    sortPlayerList()
                    tableView.reloadData()
                    self.selectedPlayer = nil
                    self.selectedIndexPath = nil
                } else {
                    // select player
                    self.selectedPlayer = (playerIsHome,playerNumber)
                    self.selectedIndexPath = indexPath
                    updateUI()
                }
            } else {
                // select another team player
                if (selectedIsHome) {
                    tableViewHome.deselectRow(at: selectedIndexPath!, animated: false)
                } else {
                    tableViewGuest.deselectRow(at: selectedIndexPath!, animated: false)
                }
                self.selectedPlayer = (playerIsHome,playerNumber)
                self.selectedIndexPath = indexPath
                updateUI()
            }
        }  else {
            // Select new player
            self.selectedPlayer = (playerIsHome,playerNumber)
            self.selectedIndexPath = indexPath
            updateUI()
        }
    }
    
    
    // ---------- Controller ----------
    
    @IBAction func quarterChange(_ sender: UISegmentedControl) {
        quarter = sender.selectedSegmentIndex + 1
        gamePlayers?.changeQuarter(quarter: quarter)
        updateUI()
    }
    
    // Team Subsutition
    @IBAction func switchHomeTeamSub(_ sender: UISwitch) {
        if sender.isOn {
            self.homeSub = true
        } else {
            self.homeSub = false
        }
    }
    @IBAction func switchGuestTeamSub(_ sender: UISwitch) {
        if sender.isOn {
            self.guestSub = true
        } else {
            self.guestSub = false
        }
    }
    
    // Two, Three Pts made/attempt
    @IBAction func singleTapImageCourt(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            viewAnchor.center = sender.location(in: view)
            performSegue(withIdentifier: "Pop Up Segue", sender: sender)
        }
    }

    
    @IBAction func stepperMinutesChanged(_ sender: UIStepper) {
        if let (home,player) = self.selectedPlayer {
            gamePlayers!.changeTime(player: player, isHome: home, step: (sender == stepperSecond ? 1 : 60) * (sender.value > 0.0 ? 1 : -1) )
        }
        sender.value = 0.0
        updateUI()
    }
    
    @IBAction func btStats(_ sender: UIButton) {
        if let (home, player) = self.selectedPlayer {
            switch sender.currentTitle! {
            case "FT Made":
                gamePlayers!.madeFT(player: player, isHome: home, step: !btRemove.isSelected)
            case "FT Attempt":
                gamePlayers!.attemptFT(player: player, isHome: home, step: !btRemove.isSelected)
            case "DR":
                gamePlayers!.incrementDR(player: player, isHome: home, step: !btRemove.isSelected)
            case "OR":
                gamePlayers!.incrementOR(player: player, isHome: home, step: !btRemove.isSelected)
            case "AST":
                gamePlayers!.incrementAST(player: player, isHome: home, step: !btRemove.isSelected)
            case "STL":
                gamePlayers!.incrementSTL(player: player, isHome: home, step: !btRemove.isSelected)
            case "BS":
                gamePlayers!.incrementBS(player: player, isHome: home, step: !btRemove.isSelected)
            case "TO":
                gamePlayers!.incrementTO(player: player, isHome: home, step: !btRemove.isSelected)
            case "PF":
                gamePlayers!.incrementPF(player: player, isHome: home, step: !btRemove.isSelected)
            case "FD":
                gamePlayers!.incrementFD(player: player, isHome: home, step: !btRemove.isSelected)
            default: break
            }
        }
        btRemove.isSelected = false
        updateUI()
    }
    
    @IBAction func btRemove(_ sender: UIButton) {
        sender.isSelected = !btRemove.isSelected
    }
    
    
    // Timer
    @IBAction func btTimeStart(_ sender: UIButton) {
        if (!isTimerRunning) {
            runTimer()
            btStart.setTitle("Pause", for: .normal);
        } else {
            if (!isPaused) {
                timer.invalidate()
                isPaused = true
                btStart.setTitle("Resume", for: .normal)
            } else {
                runTimer()
                isPaused = false
                btStart.setTitle("Pause", for: .normal)
            }
        }
    }
    
    @IBAction func btTimeStop(_ sender: UIButton) {
        timer.invalidate()
        seconds = time
        lbTimer.text = secondToString(seconds)
        
        isTimerRunning = false
        isPaused = false
        btStart.setTitle("Start", for: .normal)
    }
    
    
    // ---------- Self function ----------
    
    
    // PopUpVCDelegate function
    func recordShoot(point: CGPoint, isMade: Bool) {
        func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
            let xDist = a.x - b.x
            let yDist = a.y - b.y
            return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
        }
        
        if let (playerIsHome,playerNumber) = self.selectedPlayer {
            let width = imageCourt.frame.width
            let centre = CGPoint(x: imageCourt.frame.width * 0.5, y: imageCourt.frame.height * 0.8825 )
            
            if distance(centre, point) / imageCourt.frame.width > 0.448 {
//                print("3 points " + (isMade ?"Made":"Attempt"))
                gamePlayers?.record3Pts(player: playerNumber, isHome: playerIsHome, point: (Double(point.x / width), Double(point.y / width)), made: isMade)            } else if (point.x < centre.x - imageCourt.frame.width * 0.44 || point.x > centre.x + imageCourt.frame.width * 0.44) {
//                print("3 points " + (isMade ?"Made":"Attempt"))
                gamePlayers?.record3Pts(player: playerNumber, isHome: playerIsHome, point: (Double(point.x / width), Double(point.y / width)), made: isMade)            } else {
//                print("2 point " + (isMade ?"Made":"Attempt"))
                gamePlayers?.record2Pts(player: playerNumber, isHome: playerIsHome, point: (Double(point.x / width), Double(point.y / width)), made: isMade)
            }
            updateUI()
        }
    }
    
    func updateUI() {
        if let (home,player) = self.selectedPlayer {
            lbPlayerTeam.text = (home ? "Home" : "Guest")
            lbPlayerNumber.text = "\(player)"
            lbPlayerName.text = gamePlayers!.getName(player: player, isHome: home)
            lbPlayerScore.text = "\(gamePlayers!.getScore(player: player, isHome: home))"
            
            lbMinutes.text = secondToString(gamePlayers!.getTime(player: player, isHome: home))
            lbTwoPts.text = "\(gamePlayers!.get2PtsMade(player: player, isHome: home)) / \(gamePlayers!.get2PtsAttempt(player: player, isHome: home))"
            lbThreePts.text = "\(gamePlayers!.get3PtsMade(player: player, isHome: home)) / \(gamePlayers!.get3PtsAttempt(player: player, isHome: home))"
            lbFT.text = "\(gamePlayers!.getFTMade(player: player, isHome: home)) / \(gamePlayers!.getFTAttempt(player: player, isHome: home))"
            lbDR.text = "\(gamePlayers!.getDR(player: player, isHome: home))"
            lbOR.text = "\(gamePlayers!.getOR(player: player, isHome: home))"
            lbAST.text = "\(gamePlayers!.getAST(player: player, isHome: home))"
            lbSTL.text = "\(gamePlayers!.getSTL(player: player, isHome: home))"
            lbBS.text = "\(gamePlayers!.getBS(player: player, isHome: home))"
            lbTO.text = "\(gamePlayers!.getTO(player: player, isHome: home))"
            lbPF.text = "\(gamePlayers!.getPF(player: player, isHome: home))"
            lbFD.text = "\(gamePlayers!.getFD(player: player, isHome: home))"
            
            
        } else {
            lbPlayerTeam.text = ""
            lbPlayerNumber.text = ""
            lbPlayerName.text = ""
            lbPlayerScore.text = ""
        }
        let scores = gamePlayers!.getScores()
        tfHomeScore1.text = gamePlayers!.getQuarter() >= 1 ? "\(scores[0][0])" : ""
        tfHomeScore2.text = gamePlayers!.getQuarter() >= 2 ? "\(scores[0][1])" : ""
        tfHomeScore3.text = gamePlayers!.getQuarter() >= 3 ? "\(scores[0][2])" : ""
        tfHomeScore4.text = gamePlayers!.getQuarter() >= 4 ? "\(scores[0][3])" : ""
        tfHomeScoreOT.text = gamePlayers!.getQuarter() >= 5 ? "\(scores[0][4])" : ""
        tfGuestScore1.text = gamePlayers!.getQuarter() >= 1 ? "\(scores[1][0])" : ""
        tfGuestScore2.text = gamePlayers!.getQuarter() >= 2 ? "\(scores[1][1])" : ""
        tfGuestScore3.text = gamePlayers!.getQuarter() >= 3 ? "\(scores[1][2])" : ""
        tfGuestScore4.text = gamePlayers!.getQuarter() >= 4 ? "\(scores[1][3])" : ""
        tfGuestScoreOT.text = gamePlayers!.getQuarter() >= 5 ? "\(scores[1][4])" : ""
        
        lbHomeTeamScore.text = "\(gamePlayers!.getTotalScore(isHome: true))"
        lbGuestTeamScore.text = "\(gamePlayers!.getTotalScore(isHome: false))"
        drawShootingViews()
        
    }
    
    func drawShootingViews() {
        
        for shootingView in shootingViews {
            shootingView.removeFromSuperview()
        }
        shootingViews = []
        
        if let (home, player) = selectedPlayer {
            
            var records: [(Double,Double,Bool)] = []
            records += gamePlayers!.get2Pts(player: player, isHome: home)
            records += gamePlayers!.get3Pts(player: player, isHome: home)
            
            let width = Double(imageCourt.frame.width)
            let radius = CGFloat( imageCourt.frame.width / 75)
            
            for (posX, posY, isMade) in records {
                let point = view.convert(CGPoint(x: posX * width, y: posY * width), from: imageCourt)
                let shootingView = ShootingView(frame: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
                shootingView.made = isMade
                shootingViews.append(shootingView)
            }
        }
        for shootingView in shootingViews {
            self.view.addSubview(shootingView)
        }
    }
    
    func sortPlayerList() {
        homeTeamPlayers[0].sort()
        homeTeamPlayers[1].sort()
        guestTeamPlayers[0].sort()
        guestTeamPlayers[1].sort()
    }

    
    func runTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(GameStatViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        if (seconds < 1) {
            timer.invalidate()
            return
        }
        seconds -= 1     //This will decrement(count down)the seconds.
        lbTimer.text = secondToString(seconds)
        
        gamePlayers?.incrementTime(homeTeamPlayers: homeTeamPlayers[0], guestTeamPlayers: guestTeamPlayers[0])
        updateUI()
    }
    

}
