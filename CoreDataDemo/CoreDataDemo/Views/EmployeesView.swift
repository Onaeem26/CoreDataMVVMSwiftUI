//
//  EmployeesView.swift
//  CoreDataDemo
//
//  Created by Muhammad Osama Naeem on 1/22/23.
//

import SwiftUI

struct EmployeesView: View {
    @ObservedObject var viewModel : EmployeesViewModel
    @State var employeeName: String = ""
    
    init(company: Company) {
        self.viewModel = EmployeesViewModel(company: company)
        viewModel.fetchEmployees()
    }
    
    var body: some View {
        VStack {
            
            HStack {
                TextField("Enter Employee Name", text: $employeeName)
                    .font(.headline)
                    .padding(.leading)
                    .frame(height: 55)
                    .background(Color(uiColor: .systemGray5))
                    .cornerRadius(5)
                
                Button {
                    viewModel.addEmployee(employeeName: employeeName)
                    self.employeeName = ""
                } label: {
                    Text("Add")
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            ScrollView {
                ForEach(viewModel.employeesArray, id: \.id) { item in
                    VStack(alignment: .leading) {
                        Text(item.unwrappedName)
                            .fontWeight(.semibold)
                            .font(.headline)
                        Text(item.company?.title ?? "")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }.navigationTitle("Employees")
    }
}

