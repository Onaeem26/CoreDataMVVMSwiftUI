# CoreDataMVVMSwiftUI
Implementing CoreData in SwiftUI project using Model View View-Model (MVVM) architecture.

<img width="858" alt="Screenshot 2023-01-23 at 2 20 53 PM" src="https://user-images.githubusercontent.com/38010678/214130391-30ab3426-b5c4-4482-a01f-f161564b9e3a.png">


I would like to start off by saying that this is not the only way to implement CoreData and there are various ways you can do it. This is just my way of implementing CoreData using MVVM architecture. Any suggestions, or feedback is highly appreciated. 

<h2>Model-View-ViewModel Architecture</h2> 
With SwiftUI and Combine, we are beginning to see more and more projects using MVVM architecture. Here are the basics of such an architecture. We want the View and the ViewModel to communicate with each other. The view observe certain properties in the ViewModel, and when those properties change, the view gets reconfigured. The model is basically a simple domain object that we use to organise our data. 

In this project, the CoreData is storing all of our data, and we will use viewModel to implement the logic for fetching, adding, deleting and updating data. The view will ask the viewModel to perform the aforementioned tasks, and when the viewModel perform those tasks it will tell the view to reconfigure itself to reflect the changes. 

While CoreData comes with property wrappers such as `@FetchRequest` that helps us fetch entity data from core data, this property wrapper only works inside a `View` and not inside a `ObservableObject` which our ViewModel is. So, we will create our own fetch request method and update the `@Published` once we get the data.

Our project also contains a `One to Many` relationship between two entities - `Company -->> Employees`. We will implement a viewModel that takes care of such a relationship as well. 

<h3>Core Data Setup </h3> 
When you create an Xcode project using SwiftUI and CoreData, Xcode generates a `PersistenceController` class which is a singleton. This singleton will help us access `ViewContext` across various ViewModel files. This is how the `PersistenceController` file will look like:


```swift
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CoreDataDemo")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
```

Next head over to the CoreData data model file and add an entity and attributes. We will add two entities. First will be `Company` that will have three properties: `id`, `title`, `owner`. The other entity will be `Employee` which will contain two attributes `id`, `name` - Set up the relation between company and employee as one to many and generate the class files, we will tweak these files later on. 

<h3>View Models</h3>
So, now that our CoreData model files have been generated and set up. Now its time to create the ViewModels. Probably the most important part of this whole architecture. Let's start with `CompanyViewModel`. 

```swift
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
```

The above ViewModel file has one published property which is an array of type `Company`. Then we have a `fetchCompanyData` function in which we have created a `NSFetchRequest`. The beauty of doing the whole Core Data fetch this way is that we can implement custom sorting descriptors and predicate inside this ViewModel. So, if a user wants to order the items in a particular way, we can pass in the parameter, generate a predicate and pass it to our fetch request. We can access our `ViewContext` the main class that allows us to communicate with the persistence container using the `PersistenceController` singleton. We pass our fetch request and get the array of type company. We assign it to the `@Published` property and thats it! 

Similarly, we can add data to the db using the `addDataToCoreData(companyTitle: String, companyOwner: String)` function.

<h4>Employees View Model </h4> 

This one is interesting, since this is connected to the company entity. So, we need access to the Company entity. Here is how we can implement such a ViewModel: 

```swift
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
```

Before, explaining the above code let's tweak the NSManagedObject files the Xcode generated for us. Since, there is one to many relationship between `Company` and `Employee`, the company model contains an `NSSet` of type `Employee` called `Employees`. We will convert this to an array so that we can use it with SwiftUI easily: 

```swift
extension Company {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Company> {
        return NSFetchRequest<Company>(entityName: "Company")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var owner: String?
    @NSManaged public var title: String?
    @NSManaged public var employees: NSSet?
    
    public var employeesArray: [Employee] {
        let employeeSet = employees as? Set<Employee> ?? []
        
        return employeeSet.sorted {
            $0.unwrappedName > $1.unwrappedName
        }
    }

}
```
Here we are creating a computed property of `employeesArray` that returns the `NSSet` as an array. Now, lets get back to the ViewModel. We will use dependency injection to initialize the class. We will pass the `Company` entity to the ViewModel, and then assign `company.employeesArray` to the `@Published` property of employees in the `fetchEmployees` function. Similarly, we can implement the `addEmployee` function as well and save the new object in Core Data. 

Now, let's move our attention the `Views`. I will discuss `EmployeesView` since it requires DI to be able to initialize the `EmployeesViewModel`. On tapping the company item in the list, we will navigate to the `EmployeesView`. However, the view model for this view requires company entity so we will initialize this view like this:

```swift
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

```

You can see we have passing the company through the constructor, and the ViewModel is initialized inside the init method by passing that company model to it. Now, we can access the employees for that company inside the ForEach loop by just saying `viewModel.employeesArray`




https://user-images.githubusercontent.com/38010678/214129637-dbed9ed9-387c-4f4d-8829-70fc868e5e48.mov

