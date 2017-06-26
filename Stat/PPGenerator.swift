//
//  PPGenerator.swift
//  Stat
//
//  Created by William on 19/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit
import Foundation

class PPGenerator {
    
    // String
    let pathToPPHTMLTemplate = Bundle.main.path(forResource: "pp", ofType: "html")
    
    let pathToPPTableTemplate = Bundle.main.path(forResource: "pp_table", ofType: "html")
    
    let pathToPPItemHTMLTemplate = Bundle.main.path(forResource: "pp_item", ofType: "html")
    
    var gameTitle = ""
    
    var gameDate = ""
    
    var directory = ""
    
    var pdfFilename: String!
    
    // Model
    var game: Game
    var quarter: Int
    
    init(game: Game) {
        self.game = game
        self.quarter = Int(game.quarter)
        self.gameTitle = game.homeTeam!.name! + " : " + game.guestTeam!.name!
        self.gameDate = DateFormatter.localizedString(from: game.time! as Date, dateStyle: .short, timeStyle: .short)
        self.directory = game.homeTeam!.name! + " - " + game.guestTeam!.name!
        self.pdfFilename = "pp"
    }
    
    func genPP(completion: @escaping () -> () ) {
        // create directory
        createDirectory(folderName: directory)
        
        // gen PP PDF
        for i in 1...quarter {
            genQuarterPPPDF(quarter: i, completion: completion)
        }
    }
    
    func genQuarterPPPDF(quarter: Int, completion: @escaping () -> () ) {
        
        // Do in background thread
        DispatchQueue.global(qos: .userInteractive).async {
            let quarterGameLogs = (self.game.gameLogs?.allObjects as! [GameLog]).filter{ $0.quarter == Int16(quarter) }.sorted(by: { $0.id < $1.id })

            let HTMLContent = self.renderQuarterPP(quarterGameLogs: quarterGameLogs)
            
            // Do in main thread
            DispatchQueue.main.async {
                
                // 1.2 Create print formatter
                
                let fmt = UIMarkupTextPrintFormatter(markupText: HTMLContent)
                
                // 2. Assign print formatter to UIPrintPageRenderer
                
                let render = UIPrintPageRendererForPP()
                render.setUp(title: self.gameTitle, time: self.gameDate, quarter: quarter)
                render.addPrintFormatter(fmt, startingAtPageAt: 0)
                
                // 3. Assign paperRect and printableRect
                
                let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
                let printable = page.insetBy(dx: 20, dy: 20)
                
                render.setValue(NSValue(cgRect: page), forKey: "paperRect")
                render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
                
                // 4. Create PDF context and draw
                
                let pdfData = NSMutableData()
                
                UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
                
                for i in 1...render.numberOfPages {
                    
                    UIGraphicsBeginPDFPage();
                    let bounds = UIGraphicsGetPDFContextBounds()
                    render.drawPage(at: i - 1, in: bounds)
                    
                }
                
                UIGraphicsEndPDFContext();
                
                // 5. Save PDF file
                
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                
                pdfData.write(toFile: "\(documentsPath)/" + self.directory + "/" + self.pdfFilename + "\(quarter)" + ".pdf", atomically: true)
                
                // 6. Complete
                if (quarter==self.quarter) {
                    completion()
                }
            }

            
        }
        
    }
    
    func renderQuarterPP(quarterGameLogs: [GameLog]) -> String {
        
        do {
            // Load the PP HTML template code into a String variable.
            var HTMLContent = try String(contentsOfFile: pathToPPHTMLTemplate!)
            
            let ppTables = try renderPPTables(quarterGameLogs: quarterGameLogs)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PP_TABLES#", with: ppTables)
            
            
            return HTMLContent
        
        } catch {
            print("Unable to open and use PP HTML template files.")
        }
        return ""
    }
    
    func renderPPItems(quarterGameLogs: [GameLog]) throws -> [String] {
        var ppItems = [String](repeating: "", count: (quarterGameLogs.count / 25 + 1))
        
        var i = 0
        for gamelog in quarterGameLogs {
            let player = (gamelog.isHome ? "H " : "G ") + "\(gamelog.player)"
            let record = gamelog.record!
            
            var ppItemContent = try String(contentsOfFile: pathToPPItemHTMLTemplate!)
            ppItemContent = ppItemContent.replacingOccurrences(of: "#PLAYER#", with: player)
            ppItemContent = ppItemContent.replacingOccurrences(of: "#RECORD#", with: record)
            
            ppItems[i/25] += ppItemContent
            i += 1
        }
        
        return ppItems
    }
    
    func testRenderPPItems(total: Int) throws -> [String] {
        var ppItems = [String](repeatElement("", count: (total / 25 + 1)))
        
        for i in 0...(total) {
            
            let ppItemContent = try String(contentsOfFile: pathToPPItemHTMLTemplate!)
            
            ppItems[i/25] += ppItemContent
        }
        
        return ppItems
    }
    
    func renderPPTables(quarterGameLogs: [GameLog]) throws -> String {
        var ppTables = ""
        let ppTableItems = try renderPPItems(quarterGameLogs: quarterGameLogs)
        for ppTableItem in ppTableItems {
            var ppTableContent = try String(contentsOfFile: pathToPPTableTemplate!)
            ppTableContent = ppTableContent.replacingOccurrences(of: "#PP_ITEMS#", with: ppTableItem)
            ppTables += ppTableContent
        }
        return ppTables
    }
    
}


class UIPrintPageRendererForPP: UIPrintPageRenderer {
    
    var title = ""
    var time = ""
    var quarter = 0
    
    override init() {
        super.init()
        self.headerHeight = 80.0
        self.footerHeight = 50.0
    }
    
    func setUp(title: String, time: String, quarter: Int) {
        self.title = title
        self.time = time
        self.quarter = quarter
    }
    
    override func drawHeaderForPage(at pageIndex: Int, in headerRect: CGRect) {
        let titleFont = UIFont.boldSystemFont(ofSize: 25)
        let titleAttributes = [NSFontAttributeName: titleFont, NSForegroundColorAttributeName: UIColor.black]
        (title as NSString).draw(at: CGPoint(x:30,y:20), withAttributes: titleAttributes)
        
        let timeFont = UIFont.systemFont(ofSize: 15)
        let timeAttributes = [NSFontAttributeName: timeFont, NSForegroundColorAttributeName: UIColor.black]
        (time as NSString).draw(at: CGPoint(x:30,y:60), withAttributes: timeAttributes)
        
        let quarterText = "Quarter: " + (quarter > 4 ? "OT" + "\(quarter-1)" : "\(quarter)")
        let quarterFont = UIFont.systemFont(ofSize: 15)
        let quarterAttributes = [NSFontAttributeName: quarterFont, NSForegroundColorAttributeName: UIColor.black]
        (quarterText as NSString).draw(at: CGPoint(x:450,y:60), withAttributes: quarterAttributes)
        
    }
    
    override func drawFooterForPage(at pageIndex: Int, in footerRect: CGRect) {
        let footerText = "\(pageIndex+1)"
        
        let font = UIFont.systemFont(ofSize: 14)
        let textSize = getTextSize(text: footerText, font: font)
        
        let centerX = footerRect.size.width/2 - textSize.width/2
        let centerY = footerRect.origin.y + self.footerHeight/2 - textSize.height/2
        let attributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.black]
        
        footerText.draw(at: CGPoint(x: centerX, y: centerY), withAttributes: attributes)
        
        
        
    }
    
    func getTextSize(text: String, font: UIFont!, textAttributes: [String: AnyObject]! = nil) -> CGSize {
        let testLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.paperRect.size.width, height: footerHeight))
        if let attributes = textAttributes {
            testLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
        else {
            testLabel.text = text
            testLabel.font = font!
        }
        
        testLabel.sizeToFit()
        
        return testLabel.frame.size
    }
}
