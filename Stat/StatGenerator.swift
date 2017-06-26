//
//  StatGenerator.swift
//  Stat
//
//  Created by William on 16/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit

class StatGenerator {
    
    // String
    let pathToStatsHTMLTemplate = Bundle.main.path(forResource: "stats", ofType: "html")
    
    let pathToInfoItemHTMLTemplate = Bundle.main.path(forResource: "info_item", ofType: "html")
    
    let pathToStatItemHTMLTemplate = Bundle.main.path(forResource: "stat_item", ofType: "html")
    
    var gameTitle = ""
    
    var gameDate = ""
    
    var directory = ""
    
    var pdfFilename: String!
    
    // Model
    var game: Game
    var gamePlayers: GamePlayers
    
    init(game: Game) {
        self.game = game
        self.gamePlayers = GamePlayers(game: game, appDelegate: nil)
        self.gameTitle = game.homeTeam!.name! + " : " + game.guestTeam!.name!
        self.gameDate = DateFormatter.localizedString(from: game.time! as Date, dateStyle: .medium, timeStyle: .short)
        self.directory = game.homeTeam!.name! + " - " + game.guestTeam!.name!
        self.pdfFilename = "stat.pdf"
    }
    
    func genStatPDF(completion: @escaping () -> () ) {
        // create directory
        createDirectory(folderName: directory)
        
        // Do in background thread
        DispatchQueue.global(qos: .userInteractive).async {
            
            // 1.1 Generate Content
            
            let homeHTMLContent = self.renderTeamStat(isHome: true)
            let guestHTMLContent = self.renderTeamStat(isHome: false)
            
            
            // Do in main thread
            DispatchQueue.main.async {
                
                // 1.2 Create print formatter
                
                let fmt1 = UIMarkupTextPrintFormatter(markupText: homeHTMLContent!)
                let fmt2 = UIMarkupTextPrintFormatter(markupText: guestHTMLContent!)
                
                // 2. Assign print formatter to UIPrintPageRenderer
                
                let render = UIPrintPageRenderer()
                render.addPrintFormatter(fmt1, startingAtPageAt: 0)
                render.addPrintFormatter(fmt2, startingAtPageAt: 1)
                
                // 3. Assign paperRect and printableRect
                
                let page = CGRect(x: 0, y: 0, width: 842, height: 595) // A4, 72 dpi, landscape
                let printable = page.insetBy(dx: 20, dy: 20)
                
                render.setValue(NSValue(cgRect: page), forKey: "paperRect")
                render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
                
                // 4. Create PDF context and draw
                
                let pdfData = NSMutableData()
                
                UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: 842, height: 595), nil)
                
                for i in 1...render.numberOfPages {
                    
                    UIGraphicsBeginPDFPage();
                    let bounds = UIGraphicsGetPDFContextBounds()
                    render.drawPage(at: i - 1, in: bounds)
                    
                }
                
                UIGraphicsEndPDFContext();
                
                // 5. Save PDF file
                
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                
                pdfData.write(toFile: "\(documentsPath)/" + self.directory + "/" + self.pdfFilename, atomically: true)
                
                // 6. Complete
                completion()
            }
            
        }

        
    }
    
    func renderTeamStat(isHome: Bool) -> String! {
        
        do {
            // Load the stat HTML template code into a String variable.
            var HTMLContent = try String(contentsOfFile: pathToStatsHTMLTemplate!)
            
            // Generate Info and Stat items
            let infoItems = try renderGameInfo(game: game, isHome: isHome)
            let statItems = try renderStatInfo(game: game, isHome: isHome)
            
            // Replace the placeholders for the Info Items and Stat Items
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TITLE#", with: gameTitle)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TIME#", with: gameDate)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#INFO_ITEMS#", with: infoItems!)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#STAT_ITEMS#", with: statItems!)
            
            return HTMLContent
            
        }
        catch {
            print("Unable to open and use Stats HTML template files.")
        }
        
        return nil
    }
    
    
    func renderGameInfo(game:Game, isHome: Bool) throws -> String! {
        var infoItems = ""
        
        let scores = gamePlayers.getScores()

        for temp in [true, false] {
            let team = temp ? game.homeTeam : game.guestTeam
            let teamscores = temp ? scores[0] : scores[1]
            var infoItemContent = try String(contentsOfFile: pathToInfoItemHTMLTemplate!)
            
            var teamName = (team?.name)!
            if (isHome == temp
                ) {
                teamName = "<b><u>" + teamName + "</b></u>"
            }
            infoItemContent = infoItemContent.replacingOccurrences(of: "#NAME#", with: teamName)
            
            infoItemContent = infoItemContent.replacingOccurrences(of: "#1#", with: game.quarter >= 1 ? "\(teamscores[0])" : "")
            
            infoItemContent = infoItemContent.replacingOccurrences(of: "#2#", with: game.quarter >= 2 ? "\(teamscores[1])" : "")
            
            infoItemContent = infoItemContent.replacingOccurrences(of: "#3#", with: game.quarter >= 3 ? "\(teamscores[2])" : "")
            
            infoItemContent = infoItemContent.replacingOccurrences(of: "#4#", with: game.quarter >= 4 ? "\(teamscores[3])" : "")
            
            infoItemContent = infoItemContent.replacingOccurrences(of: "#OT#", with: game.quarter == 5 ? "\(teamscores[4])" : "")
            
            infoItemContent = infoItemContent.replacingOccurrences(of: "#SCORE#", with: "\(gamePlayers.getTotalScore(isHome: temp))")

            
            infoItems += infoItemContent
        }

        return infoItems
    }
    
    func renderStatInfo(game: Game, isHome: Bool) throws -> String! {
        var statItems = ""
        let playerList = isHome ? gamePlayers.homeTeamPlayers.keys.sorted() : gamePlayers.guestTeamPlayers.keys.sorted()
        
        // Player Stats
        for player in playerList {
            let twoPts = [gamePlayers.get2PtsMade(player: player, isHome: isHome),gamePlayers.get2PtsAttempt(player: player, isHome: isHome)]
            let threePts = [gamePlayers.get3PtsMade(player: player, isHome: isHome),gamePlayers.get3PtsAttempt(player: player, isHome: isHome)]
            let fg = [twoPts[0] + threePts[0], twoPts[1] + threePts[1]]
            let ft = [gamePlayers.getFTMade(player: player, isHome: isHome),gamePlayers.getFTAttempt(player: player, isHome: isHome)]
            

            var statItemContent = try String(contentsOfFile: pathToStatItemHTMLTemplate!)
            
            statItemContent = statItemContent.replacingOccurrences(of: "#NUMBER#", with: "\(player)")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#NAME#", with: gamePlayers.getName(player: player, isHome: isHome))
            
            statItemContent = statItemContent.replacingOccurrences(of: "#MINUTES#", with: "\(secondToString(gamePlayers.getTime(player: player, isHome: isHome)))")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#2PTS#", with: "\(twoPts[0])-\(twoPts[1])")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#2PTS_FG#", with: twoPts[0] > 0 ? "\((Double(twoPts[0])/Double(twoPts[1])*1000).rounded()/10)" : "0.0")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#3PTS#", with: "\(threePts[0])-\(threePts[1])")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#3PTS_FG#", with: threePts[1] > 0 ? "\((Double(threePts[0])/Double(threePts[1])*1000).rounded()/10)" : "0.0")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#FG#", with: fg[1] > 0 ? "\((Double(fg[0])/Double(fg[1])*1000).rounded()/10)" : "0.0")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#FT#", with: "\(ft[0])-\(ft[1])")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#FT_FG#", with: ft[1] > 0 ? "\((Double(ft[0])/Double(ft[1])*1000).rounded()/10)" : "0.0")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#DR#", with: "\(gamePlayers.getDR(player: player, isHome: isHome))")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#OR#", with: "\(gamePlayers.getOR(player: player, isHome: isHome))")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#REB#", with: "\(gamePlayers.getOR(player: player, isHome: isHome) + gamePlayers.getDR(player: player, isHome: isHome))")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#AST#", with: "\(gamePlayers.getAST(player: player, isHome: isHome))")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#ST#", with: "\(gamePlayers.getSTL(player: player, isHome: isHome))")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#BS#", with: "\(gamePlayers.getBS(player: player, isHome: isHome))")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#TO#", with: "\(gamePlayers.getTO(player: player, isHome: isHome))")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#PF#", with: "\(gamePlayers.getPF(player: player, isHome: isHome))")

            statItemContent = statItemContent.replacingOccurrences(of: "#FD#", with: "\(gamePlayers.getFD(player: player, isHome: isHome))")
            
            statItemContent = statItemContent.replacingOccurrences(of: "#PTS#", with: "\(gamePlayers.getScore(player: player, isHome: isHome))")
            
            
            statItems += statItemContent
        }
        
        // Team Stats
        let twoPts = [gamePlayers.get2PtsMade(isHome: isHome),gamePlayers.get2PtsAttempt(isHome: isHome)]
        let threePts = [gamePlayers.get3PtsMade(isHome: isHome),gamePlayers.get3PtsAttempt(isHome: isHome)]
        let fg = [twoPts[0] + threePts[0], twoPts[1] + threePts[1]]
        let ft = [gamePlayers.getFTMade(isHome: isHome),gamePlayers.getFTAttempt(isHome: isHome)]
        
        var statItemContent = try String(contentsOfFile: pathToStatItemHTMLTemplate!)
        
        statItemContent = statItemContent.replacingOccurrences(of: "#NUMBER#", with: "")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#NAME#", with: "Total")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#MINUTES#", with: "\(secondToString(gamePlayers.getTime(isHome: isHome)))")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#2PTS#", with: "\(twoPts[0])-\(twoPts[1])")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#2PTS_FG#", with: twoPts[0] > 0 ? "\((Double(twoPts[0])/Double(twoPts[1])*1000).rounded()/10)" : "0.0")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#3PTS#", with: "\(threePts[0])-\(threePts[1])")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#3PTS_FG#", with: threePts[1] > 0 ? "\((Double(threePts[0])/Double(threePts[1])*1000).rounded()/10)" : "0.0")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#FG#", with: fg[1] > 0 ? "\((Double(fg[0])/Double(fg[1])*1000).rounded()/10)" : "0.0")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#FT#", with: "\(ft[0])-\(ft[1])")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#FT_FG#", with: ft[1] > 0 ? "\((Double(ft[0])/Double(ft[1])*1000).rounded()/10)" : "0.0")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#DR#", with: "\(gamePlayers.getDR(isHome: isHome))")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#OR#", with: "\(gamePlayers.getOR(isHome: isHome))")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#REB#", with: "\(gamePlayers.getOR(isHome: isHome) + gamePlayers.getDR(isHome: isHome))")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#AST#", with: "\(gamePlayers.getAST(isHome: isHome))")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#ST#", with: "\(gamePlayers.getSTL(isHome: isHome))")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#BS#", with: "\(gamePlayers.getBS(isHome: isHome))")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#TO#", with: "\(gamePlayers.getTO(isHome: isHome))")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#PF#", with: "\(gamePlayers.getPF(isHome: isHome))")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#FD#", with: "\(gamePlayers.getFD(isHome: isHome))")
        
        statItemContent = statItemContent.replacingOccurrences(of: "#PTS#", with: "\(gamePlayers.getTotalScore(isHome: isHome))")
        
        statItems += statItemContent
        
        return statItems
    }
    
    
    
}

// Useful function
func secondToString(_ second: Int) -> String {
    let minutes = second / 60
    let seconds = second % 60
    return String(format:"%02i:%02i", minutes, seconds)
}


