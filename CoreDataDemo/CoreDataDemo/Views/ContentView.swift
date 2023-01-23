//
//  ContentView.swift
//  CoreDataDemo
//
//  Created by Muhammad Osama Naeem on 1/22/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var viewModel = CompanyViewModel()
    @State var companyName: String = ""
    @State var companyOwner: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack {
                        TextField("Enter Company Name", text: $companyName)
                            .font(.headline)
                            .padding(.leading)
                            .frame(height: 55)
                            .background(Color(uiColor: .systemGray5))
                            .cornerRadius(5)
                            
                        TextField("Enter Owner Name", text: $companyOwner)
                            .font(.headline)
                            .padding(.leading)
                            .frame(height: 55)
                            .background(Color(uiColor: .systemGray5))
                            .cornerRadius(5)
                    }
                    
                    Button {
                        viewModel.addDataToCoreData(companyTitle: companyName, companyOwner: companyOwner)
                        self.companyName = ""
                        self.companyOwner = ""
                    } label: {
                        Text("Add")
                    }

                }.padding(.horizontal)
                
                ScrollView {
                    ForEach(viewModel.companyArray, id: \.id) { item in
                        NavigationLink {
                            EmployeesView(company: item)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(item.title ?? "")
                                    .fontWeight(.semibold)
                                    .font(.headline)
                                Text(item.owner ?? "")
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.bottom)
                        }

                        
                    }
                }
            }.navigationTitle("Company")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
