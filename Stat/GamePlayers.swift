//
//  GamePlayers.swift
//  Stat
//
//  Created by William on 4/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import Foundation
import CoreData

class GamePlayers {
    
    // ---------- Model ----------
    var game: Game?
    var team: Team?
    
    var homeTeam: Team
    var guestTeam: Team
    
    var homeTeamPlayers: [Int:Player] = [:]
    var guestTeamPlayers: [Int:Player] = [:]
    
    var homeTeamGameStats: [Int:GameStat] = [:]
    var guestTeamGameStats: [Int:GameStat] = [:]
    
    var homeScores: [GameScore]
    var guestScores: [GameScore]
    
    var players: [Int:Player] = [:]
    var gameStats: [Int:GameStat] = [:]
    
    var quarter: Int
    
    var context: NSManagedObjectContext?
    
    init(game: Game, appDelegate: AppDelegate?) {
        self.game = game
        self.homeTeam = game.homeTeam!
        self.guestTeam = game.guestTeam!
        self.context = appDelegate?.persistentContainer.viewContext
        
        if let homeGameStatList = game.homeTeamPlayersStat?.allObjects as? [GameStat] {
            for gameStat in homeGameStatList {
                self.homeTeamGameStats[Int((gameStat.player?.number)!)] = gameStat
                self.homeTeamPlayers[Int((gameStat.player?.number)!)] = gameStat.player
            }
        }
        
        if let guestGameStatList = game.guestTeamPlayerStat?.allObjects as? [GameStat] {
            for gameStat in guestGameStatList {
                self.guestTeamGameStats[Int((gameStat.player?.number)!)] = gameStat
                self.guestTeamPlayers[Int((gameStat.player?.number)!)] = gameStat.player
            }
        }
        
        self.homeScores = ((game.homeTeamScore)?.allObjects as! [GameScore]).sorted(by: { $0.quarter < $1.quarter} )
        self.guestScores = ((game.guestTeamScore)?.allObjects as! [GameScore]).sorted(by: { $0.quarter < $1.quarter} )
        
        self.quarter = Int(game.quarter)
    }
    
    

    // Update stat
    func changeQuarter(quarter: Int) {
        self.quarter = quarter
        if quarter > Int(game!.quarter) {
            game?.quarter = Int16(quarter)
        }
    }
    
    func incrementTime(homeTeamPlayers: [Int], guestTeamPlayers: [Int]) {
        for player in homeTeamPlayers {
            homeTeamGameStats[player]?.minutes += 1
        }
        for player in guestTeamPlayers {
            guestTeamGameStats[player]?.minutes += 1
        }
    }
    
    func changeTime(player: Int, isHome: Bool,step: Int) {
        if isHome {
            homeTeamGameStats[player]?.minutes += Int16(step)
            if (homeTeamGameStats[player]?.minutes)! < 0 {
                homeTeamGameStats[player]?.minutes = 0
            }
        } else {
            guestTeamGameStats[player]?.minutes += Int16(step)
            if (guestTeamGameStats[player]?.minutes)! < 0 {
                guestTeamGameStats[player]?.minutes = 0
            }
        }
    }
    
    func record2Pts(player: Int, isHome: Bool, point: (Double,Double), made: Bool) {
        let (x,y) = point
        let twoPts = TwoPts(context: context!)
        twoPts.made = made
        twoPts.posX = x
        twoPts.posY = y
        
        if isHome {
            homeTeamGameStats[player]?.addToTwoPtStats(twoPts)
            if made {
                homeScores[quarter-1].score += 2
            }
        } else {
            guestTeamGameStats[player]?.addToTwoPtStats(twoPts)
            if made {
                guestScores[quarter-1].score += 2
            }
        }
        
        createGameLog(player: player, isHome: isHome, record: "2" + (made ? "M" : "A"))
    }
    
    func record3Pts(player: Int, isHome: Bool, point: (Double,Double), made: Bool) {
        let (x,y) = point
        let threePts = ThreePts(context: context!)
        threePts.made = made
        threePts.posX = x
        threePts.posY = y
        
        if isHome {
            homeTeamGameStats[player]?.addToThreePtStats(threePts)
            if made {
                homeScores[quarter-1].score += 3
            }
        } else {
            guestTeamGameStats[player]?.addToThreePtStats(threePts)
            if made {
                guestScores[quarter-1].score += 3
            }
        }
        createGameLog(player: player, isHome: isHome, record: "3" + (made ? "M" : "A"))
    }
    
    func attemptFT(player: Int, isHome: Bool, step: Bool) {
        if isHome {
            homeTeamGameStats[player]?.ftAttempt += step ? 1 : -1
        } else {
            guestTeamGameStats[player]?.ftAttempt += step ? 1 : -1
        }
        createGameLog(player: player, isHome: isHome, record: "FTA" + (step ? "" : " X"))
    }
    
    func madeFT(player: Int, isHome: Bool, step: Bool) {
        if isHome {
            homeTeamGameStats[player]?.ftAttempt += step ? 1 : -1
            homeTeamGameStats[player]?.ftMade += step ? 1 : -1
            homeScores[quarter-1].score += step ? 1 : -1
        } else {
            guestTeamGameStats[player]?.ftAttempt += step ? 1 : -1
            guestTeamGameStats[player]?.ftMade += step ? 1 : -1
            guestScores[quarter-1].score += step ? 1 : -1
        }
        createGameLog(player: player, isHome: isHome, record: "FTM" + (step ? "" : " X"))
    }
    
    func incrementDR(player: Int, isHome: Bool, step: Bool) {
        if isHome {
            homeTeamGameStats[player]?.defReb += step ? 1 : -1
        } else {
            guestTeamGameStats[player]?.defReb += step ? 1 : -1
        }
        createGameLog(player: player, isHome: isHome, record: "DR" + (step ? "" : " X"))
    }
    
    func incrementOR(player: Int, isHome: Bool, step: Bool) {
        if isHome {
            homeTeamGameStats[player]?.offReb += step ? 1 : -1
        } else {
            guestTeamGameStats[player]?.offReb += step ? 1 : -1
        }
        createGameLog(player: player, isHome: isHome, record: "OR" + (step ? "" : " X"))
    }
    
    func incrementAST(player: Int, isHome: Bool, step: Bool) {
        if isHome {
            homeTeamGameStats[player]?.assist += step ? 1 : -1
        } else {
            guestTeamGameStats[player]?.assist += step ? 1 : -1
        }
        createGameLog(player: player, isHome: isHome, record: "AST" + (step ? "" : " X"))
    }
    
    func incrementSTL(player: Int, isHome: Bool, step: Bool) {
        if isHome {
            homeTeamGameStats[player]?.steal += step ? 1 : -1
        } else {
            guestTeamGameStats[player]?.steal += step ? 1 : -1
        }
        createGameLog(player: player, isHome: isHome, record: "STL" + (step ? "" : " X"))
    }
    
    func incrementBS(player: Int, isHome: Bool, step: Bool) {
        if isHome {
            homeTeamGameStats[player]?.blockShot += step ? 1 : -1
        } else {
            guestTeamGameStats[player]?.blockShot += step ? 1 : -1
        }
        createGameLog(player: player, isHome: isHome, record: "BS" + (step ? "" : " X"))
    }
    
    func incrementTO(player: Int, isHome: Bool, step: Bool) {
        if isHome {
            homeTeamGameStats[player]?.turnover += step ? 1 : -1
        } else {
            guestTeamGameStats[player]?.turnover += step ? 1 : -1
        }
        createGameLog(player: player, isHome: isHome, record: "TO" + (step ? "" : " X"))
    }
    
    func incrementPF(player: Int, isHome: Bool, step: Bool) {
        if isHome {
            homeTeamGameStats[player]?.foul += step ? 1 : -1
        } else {
            guestTeamGameStats[player]?.foul += step ? 1 : -1
        }
        createGameLog(player: player, isHome: isHome, record: "PF" + (step ? "" : " X"))
    }
    
    func incrementFD(player: Int, isHome: Bool, step: Bool) {
        if isHome {
            homeTeamGameStats[player]?.foulDraw += step ? 1 : -1
        } else {
            guestTeamGameStats[player]?.foulDraw += step ? 1 : -1
        }
        createGameLog(player: player, isHome: isHome, record: "FD" + (step ? "" : " X"))
    }
    
    // Get player stat
    func getName(player: Int, isHome: Bool) -> String {
        return (isHome ? homeTeamPlayers : guestTeamPlayers)[player]!.name!
    }
    
    func getScore(player: Int, isHome: Bool) -> Int {
        var score = 0
        score += get2PtsMade(player: player, isHome: isHome) * 2
        score += get3PtsMade(player: player, isHome: isHome) * 3
        score += getFTMade(player: player, isHome: isHome)
        return Int(score)
    }
    
    func getTime(player: Int, isHome: Bool) -> Int {
        return Int(((isHome ? homeTeamGameStats : guestTeamGameStats)[player]?.minutes)!)
    }
    
    func get2PtsAttempt(player: Int, isHome: Bool) -> Int {
        return get2Pts(player: player,isHome: isHome).count
    }
    
    func get2PtsMade(player: Int, isHome: Bool) -> Int {
        return get2Pts(player: player,isHome: isHome).filter{(_, _, made) -> Bool in return made}.count
    }
    
    func get2Pts(player: Int, isHome: Bool) -> [(Double,Double,Bool)]{
        var result: [(Double,Double,Bool)] = []
        for twoPts in (isHome ? homeTeamGameStats : guestTeamGameStats)[player]?.twoPtStats?.allObjects as! [TwoPts] {
            result.append((twoPts.posX, twoPts.posY, twoPts.made))
        }
        return result
    }
    
    func get3PtsAttempt(player: Int, isHome: Bool) -> Int {
        return get3Pts(player: player,isHome: isHome).count
    }
    
    func get3PtsMade(player: Int, isHome: Bool) -> Int {
        return get3Pts(player: player,isHome: isHome).filter{(_, _, made) -> Bool in return made}.count
    }
    
    func get3Pts(player: Int, isHome: Bool) -> [(Double,Double,Bool)] {
        var result: [(Double,Double,Bool)] = []
        for threePts in (isHome ? homeTeamGameStats : guestTeamGameStats)[player]?.threePtStats?.allObjects as! [ThreePts] {
            result.append((threePts.posX, threePts.posY, threePts.made))
        }
        return result
    }
    
    func getFTAttempt(player: Int, isHome: Bool) -> Int {
        return Int(((isHome ? homeTeamGameStats : guestTeamGameStats)[player]?.ftAttempt)!)
    }
    
    func getFTMade(player: Int, isHome: Bool) -> Int {
        return Int(((isHome ? homeTeamGameStats : guestTeamGameStats)[player]?.ftMade)!)
    }
    
    func getDR(player: Int, isHome: Bool) -> Int {
        return Int(((isHome ? homeTeamGameStats : guestTeamGameStats)[player]?.defReb)!)
    }
    
    func getOR(player: Int, isHome: Bool) -> Int {
        return Int(((isHome ? homeTeamGameStats : guestTeamGameStats)[player]?.offReb)!)
    }
    
    func getAST(player: Int, isHome: Bool) -> Int {
        return Int(((isHome ? homeTeamGameStats : guestTeamGameStats)[player]?.assist)!)
    }
    
    func getSTL(player: Int, isHome: Bool) -> Int {
        return Int(((isHome ? homeTeamGameStats : guestTeamGameStats)[player]?.steal)!)
    }
    
    func getBS(player: Int, isHome: Bool) -> Int {
        return Int(((isHome ? homeTeamGameStats : guestTeamGameStats)[player]?.blockShot)!)
    }
    
    func getTO(player: Int, isHome: Bool) -> Int {
        return Int(((isHome ? homeTeamGameStats : guestTeamGameStats)[player]?.turnover)!)
    }
    
    func getPF(player: Int, isHome: Bool) -> Int {
        return Int(((isHome ? homeTeamGameStats : guestTeamGameStats)[player]?.foul)!)
    }
    
    func getFD(player: Int, isHome: Bool) -> Int {
        return Int(((isHome ? homeTeamGameStats : guestTeamGameStats)[player]?.foulDraw)!)
    }
    
    // Get Game Info
    func getQuarter() -> Int {
        return Int(game!.quarter)
    }
    
    func getTotalScore(isHome: Bool) -> Int {
        var sum = 0
        for (player,_) in (isHome ? homeTeamPlayers : guestTeamPlayers) {
            sum += getScore(player: player, isHome: isHome)
        }
        return sum
    }
    
    // Get team stat
    func getScores() -> [[Int]] {
        var scores: [[Int]] = [[],[]]
        for gameScore in homeScores {
            scores[0].append(Int(gameScore.score))
        }
        for gameScore in guestScores {
            scores[1].append(Int(gameScore.score))
        }
        
        return scores
    }
    
    func getTime(isHome: Bool) -> Int {
        var sum = 0
        for (_,temp) in (isHome ? homeTeamGameStats : guestTeamGameStats) { sum += Int(temp.minutes)}
        return sum
    }
    
    func get2PtsAttempt(isHome: Bool) -> Int {
        var sum = 0
        for (player,_) in (isHome ? homeTeamPlayers : guestTeamPlayers) {
            sum += get2PtsAttempt(player: player, isHome: isHome)
        }
        return sum
    }
    
    func get2PtsMade(isHome: Bool) -> Int {
        var sum = 0
        for (player,_) in (isHome ? homeTeamPlayers : guestTeamPlayers) {
            sum += get2PtsMade(player: player, isHome: isHome)
        }
        return sum

    }

    func get3PtsAttempt(isHome: Bool) -> Int {
        var sum = 0
        for (player,_) in (isHome ? homeTeamPlayers : guestTeamPlayers) {
            sum += get3PtsAttempt(player: player, isHome: isHome)
        }
        return sum
    }
    
    func get3PtsMade(isHome: Bool) -> Int {
        var sum = 0
        for (player,_) in (isHome ? homeTeamPlayers : guestTeamPlayers) {
            sum += get3PtsMade(player: player, isHome: isHome)
        }
        return sum
    }
    
    func getFTAttempt(isHome: Bool) -> Int {
        var sum = 0
        for (_,temp) in (isHome ? homeTeamGameStats : guestTeamGameStats) { sum += Int(temp.ftAttempt)}
        return sum
    }
    
    func getFTMade(isHome: Bool) -> Int {
        var sum = 0
        for (_,temp) in (isHome ? homeTeamGameStats : guestTeamGameStats) { sum += Int(temp.ftMade)}
        return sum
    }
    
    func getDR(isHome: Bool) -> Int {
        var sum = 0
        for (_,temp) in (isHome ? homeTeamGameStats : guestTeamGameStats) { sum += Int(temp.defReb)}
        return sum
    }
    
    func getOR(isHome: Bool) -> Int {
        var sum = 0
        for (_,temp) in (isHome ? homeTeamGameStats : guestTeamGameStats) { sum += Int(temp.offReb)}
        return sum
    }
    
    func getAST(isHome: Bool) -> Int {
        var sum = 0
        for (_,temp) in (isHome ? homeTeamGameStats : guestTeamGameStats) { sum += Int(temp.assist)}
        return sum
    }
    
    func getSTL(isHome: Bool) -> Int {
        var sum = 0
        for (_,temp) in (isHome ? homeTeamGameStats : guestTeamGameStats) { sum += Int(temp.steal)}
        return sum
    }
    
    func getBS(isHome: Bool) -> Int {
        var sum = 0
        for (_,temp) in (isHome ? homeTeamGameStats : guestTeamGameStats) { sum += Int(temp.blockShot)}
        return sum
    }
    
    func getTO(isHome: Bool) -> Int {
        var sum = 0
        for (_,temp) in (isHome ? homeTeamGameStats : guestTeamGameStats) { sum += Int(temp.turnover)}
        return sum
    }
    
    func getPF(isHome: Bool) -> Int {
        var sum = 0
        for (_,temp) in (isHome ? homeTeamGameStats : guestTeamGameStats) { sum += Int(temp.foul)}
        return sum
    }
    
    func getFD(isHome: Bool) -> Int {
        var sum = 0
        for (_,temp) in (isHome ? homeTeamGameStats : guestTeamGameStats) { sum += Int(temp.foulDraw)}
        return sum
    }
    
    // function
    func createGameLog(player: Int, isHome: Bool, record: String) {
        let gameLog = GameLog(context: context!)
        gameLog.id = game!.logSize
        gameLog.quarter = Int16(quarter)
        gameLog.player = Int16(player)
        gameLog.isHome = isHome
        gameLog.record = record
        game!.addToGameLogs(gameLog)
        game!.logSize += 1
    }
    
}

