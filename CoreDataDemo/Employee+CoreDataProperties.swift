//
//  Employee+CoreDataProperties.swift
//  CoreDataDemo
//
//  Created by Muhammad Osama Naeem on 1/23/23.
//
//

import Foundation
import CoreData


extension Employee {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Employee> {
        return NSFetchRequest<Employee>(entityName: "Employee")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var company: Company?
    
    public var unwrappedName: String {
        return name ?? ""
    }

}

extension Employee : Identifiable {

}
