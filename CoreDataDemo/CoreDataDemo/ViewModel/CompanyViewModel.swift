//
//  CompanyViewModel.swift
//  CoreDataDemo
//
//  Created by Muhammad Osama Naeem on 1/22/23.
//

import Foundation
import CoreData

class CompanyViewModel: ObservableObject {
    private let viewContext = PersistenceController.shared.viewContext
    @Published var companyArray: [Company] = []
    
    init() {
        fetchCompanyData()
    }
    
    func fetchCompanyData() {
        let request = NSFetchRequest<Company>(entityName: "Company")
        
        do {
            companyArray = try viewContext.fetch(request)
        }catch {
            print("DEBUG: Some error occured while fetching")
        }
    }
    
    func addDataToCoreData(companyTitle: String, companyOwner: String) {
        let company = Company(context: viewContext)
        company.id = UUID()
        company.title = companyTitle
        company.owner = companyOwner
        
        save()
        self.fetchCompanyData()
    }
    
    func save() {
        do {
            try viewContext.save()
        }catch {
            print("Error saving")
        }
    }
}
