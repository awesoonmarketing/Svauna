//
//  CDSession+CoreDataProperties.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-30.
//
//

import Foundation
import CoreData

extension CDSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDSession> {
        return NSFetchRequest<CDSession>(entityName: "CDSession")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var type: String?
    @NSManaged public var state: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    
    @NSManaged public var segmentsData: Data?
    @NSManaged public var heartRateData: Data?
    @NSManaged public var caloriesData: Data?
    @NSManaged public var bloodOxygenData: Data?
}
