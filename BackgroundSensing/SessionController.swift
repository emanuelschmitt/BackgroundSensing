//
//  SessionController.swift
//  BackgroundSensing
//
//  Created by Emanuel Schmitt on 12.06.17.
//  Copyright © 2017 Emanuel Schmitt. All rights reserved.
//

import Foundation

public enum BodyPosture: String {
    
    case standing   = "STANDING"
    case sitting    = "SITTING"
    case lying      = "LYING"
    
    static let allValues = [standing, sitting, lying]
}

public enum TypingModality: String {
    
    case index      = "INDEX"
    case thumb      = "THUMB"
    
    static let allValues = [index, thumb]
}

public enum Mood: String {
    
    case one        = "mood-1"
    case two        = "mood-2"
    case three      = "mood-3"
    case four       = "mood-4"
    case five       = "mood-5"
    
    static let allValues = [one, two, three, four, five]
}

func generateSessionCode(_ userId: Int,_ date: Date) -> String {
    
    let userIdString = String(userId)
    let dateString = date.toDateCodeString()
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< 10 {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return userIdString + dateString + randomString
}

class SessionControlller {
    
    static let shared = SessionControlller()
    
    // MARK: - Variables
    
    let managedObjectContext = DataManager.shared.context
    
    var sessionCode: String
    var bodyPosture: String?
    var typingModality: String?
    var mood: String?
    
    init() {
        self.sessionCode = generateSessionCode(AuthenticationService.shared.userId!, Date())
    }
    
    // MARK: - Helpers
    
    func persistSession(){
        
        guard let bodyPosture = self.bodyPosture,
            let typingModality = self.typingModality,
            let mood = self.mood else {
            print("Fields in Sessioncontroller are not set.")
            return;
        }
        
        let session = Session(context: managedObjectContext)
        
        session.bodyPosture = bodyPosture
        session.typingModality = typingModality
        session.mood = mood
        session.sessionCode = sessionCode
        session.user = Int16(AuthenticationService.shared.userId!)
        session.date = Date() as NSDate

        DataManager.shared.saveContext()
    }
}
