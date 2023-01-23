//
//  EmployeesViewModel.swift
//  CoreDataDemo
//
//  Created by Muhammad Osama Naeem on 1/22/23.
//

import Foundation
import CoreData

class EmployeesViewModel: ObservableObject {
    private let viewContext = PersistenceController.shared.viewContext
    @Published var employeesArray = [Employee]()
    
    
    var company: Company // (NSManagedObject)
    
    init(company: Company) {
        self.company = company
    }
    
    func fetchEmployees() {
        employeesArray = company.employeesArray
    }
    
    func addEmployee(employeeName: String) {
        let employee = Employee(context: viewContext)
        employee.id = UUID()
        employee.name = employeeName
        
        company.addToEmployees(employee)
        save()
        fetchEmployees()
    }
    
    func save() {
        do {
            try viewContext.save()
        }catch {
            print("Error saving")
        }
    }
}
