//
//  Session+CoreDataProperties.swift
//  
//
//  Created by Emanuel Schmitt on 12.06.17.
//
//

import Foundation
import CoreData
import UIKit

extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var bodyPosture: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var mood: String?
    @NSManaged public var typingModality: String?
    @NSManaged public var user: Int16
    @NSManaged public var sessionCode: String

    public func toJSONDictionary() -> [String: Any]{
        var dict = [String: Any]()
        
        if let date = self.date as Date? {
            dict["date"] = date.toDateString()
        }
        
        dict["mood"] = (self.mood != nil) ? self.mood! : "N/A"
        dict["body_posture"] = self.bodyPosture
        dict["typing_modality"] = self.typingModality
        dict["user"] = AuthenticationService.shared.userId!
        dict["session_code"] = self.sessionCode
        dict["device_model"] = UIDevice.current.model
        
        print("Session payload")
        print(dict)
        return dict
    }
}
