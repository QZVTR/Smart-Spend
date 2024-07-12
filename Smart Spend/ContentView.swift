//
//  ContentView.swift
//  Smart Spend
//
//  Created by Edward Jermyn on 09/05/2024.
//

import SwiftUI
import CoreData
import UserNotifications
 



struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @State private var isShowingAddExpenseView = false
    @FetchRequest(sortDescriptors: []) var incomingE: FetchedResults<Eincoming>
    @FetchRequest(sortDescriptors: []) var incomingInv: FetchedResults<InvIncoming>
    @FetchRequest(sortDescriptors: []) var incomingO: FetchedResults<OIncome>
    @FetchRequest(sortDescriptors: []) var expenses: FetchedResults<Outgoing>
    //@AppStorage("selectedCurrency") private var selectedCurrency: String = "GBP"
    @AppStorage("selectedCurrencySymbol") private var selectedCurrencySymbol: String = "£"

    @State private var latestIn = 0.0
    @State private var latestOut = 0.0
    
    @State private var inAndOut: Array<Any> = []
    @State private var mixedOrdered: Array<Any> = []
    
    @State private var showingSelectedExpenseView = false
    @State private var selectedExpense: Outgoing? = nil
    
    @State private var showingSalaryIncomeView = false
    @State private var selectedSalary: Eincoming? = nil
    
    @State private var showingInvestmentIncomeView = false
    @State private var selectedInvestment: InvIncoming? = nil
    
    @State private var showingOtherIncomeView = false
    @State private var selectedOther: OIncome? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("+\(selectedCurrencySymbol)\(modifyPriceForView(price:latestIn))")
                        .foregroundColor(.green)
                    Text("\(selectedCurrencySymbol)\(String(totalCombined()))")
                    Text("-\(selectedCurrencySymbol)\(modifyPriceForView(price:latestOut))")
                        .foregroundColor(.red)
                }

                
                VStack {
              
                    List {
                        ForEach(incomingE) { income in
                            NavigationLink {
                                //selectedSalary = income // Identify selected expense
                                //showingSalaryIncomeView.toggle() // Toggle navigation link
                                SelectedIncomeSalary(income: income)
                            } label: {
                                Text("Salary: \(selectedCurrencySymbol)\(modifyPriceForView(price:income.salary))")
                                    .foregroundColor(.green)
                            }
                        }
                        .onDelete(perform: removeIncomeEmployment)
                        
                        
                        
                        
                        ForEach(incomingInv) { income in
                            NavigationLink {
                                //selectedInvestment = income // Identify selected expense
                                //showingInvestmentIncomeView.toggle() // Toggle navigation link
                                SelectedIncomeInvestment(income: income)
                            } label: {
                                Text("\(income.name ?? "Unknown") Total: \(selectedCurrencySymbol)\(modifyPriceForView(price:income.total))")
                                    .foregroundColor(.green)
                            }
                        }
                        .onDelete(perform: removeIncomeInvestment)
                     
                        
                        
                        ForEach(incomingO) { income in
                            NavigationLink {
                                //selectedOther = income // Identify selected expense
                                //showingOtherIncomeView.toggle() // Toggle navigation link
                                SelectedIncomeOther(income: income)
                            } label: {
                                Text("Amount: \(selectedCurrencySymbol)\(modifyPriceForView(price:income.amount))")
                                    .foregroundColor(.green)
                            }
                        }
                        .onDelete(perform: removeIncomeOther)
                  
                        
                        ForEach(expenses) { expense in
                            NavigationLink {
                                //selectedExpense = expense // Identify selected expense
                                //showingSelectedExpenseView.toggle() // Toggle navigation link
                                SelectedExpenseView(expense: expense)
                            } label: {
                                Text("\(expense.title ?? "Unknown"): \(selectedCurrencySymbol)\(String(expense.price))")
                                    .foregroundColor(.red)
                            }
                        }
                        .onDelete(perform: removeExpense)
      
                    }
                }
            }
            .onAppear {
                latestIn = getLatestIn()
                latestOut = getLatestOut()
                inAndOut = getDatesOrdered()
                checkExpenseDate()
                checkSalaryIncomeDate()
            }
            .navigationTitle("Total")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    func checkSalaryIncomeDate() {
        let currentDate = Date() // Get the current date
        let calendar = Calendar.current
        
        // Request permission to send notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
        
        for salary in incomingE {
            let salaryDate = salary.date
            if let oneMonthAfterSalaryDate = calendar.date(byAdding: .month, value: 1, to: salaryDate!) {
                if calendar.isDate(currentDate, inSameDayAs: oneMonthAfterSalaryDate) {
                    print("Salary is month after input")
                    salary.date = Date.now
                    salary.runningTotal +=  salary.salary
                    try? moc.save()
                    
                    // Create and send notification
                    let content = UNMutableNotificationContent()
                    content.title = "Salary Update"
                    content.body = "Salary is month after input"
                    content.sound = UNNotificationSound.default
                    
                    // Schedule notifications for each month
                    for i in 1...12 {
                        if let nextMonthDate = calendar.date(byAdding: .month, value: i, to: currentDate) {
                            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextMonthDate)
                            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                            
                            // Create a request
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            
                            // Add the notification request
                            UNUserNotificationCenter.current().add(request) { (error) in
                                if let error = error {
                                    print("Error adding notification: \(error)")
                                }
                            }
                        }
                    }
                } else {
                    print("Salary is not one month after the inputted date.")
                }
            }
        }
    }
    
    
    
    func checkExpenseDate() {
        let currentDate = Date() // Get the current date
        let calendar = Calendar.current
        
        for expense in expenses {
            if expense.reoccur {
                let timeFrame = expense.updatedTimeFrame
                let expenseDate = expense.date
                 
                if timeFrame == "Weekly" {
                    if let oneWeekAfterExpenseDate = calendar.date(byAdding: .weekOfYear, value: 1, to: expenseDate!) {
                        if calendar.isDate(currentDate, inSameDayAs: oneWeekAfterExpenseDate) {
                            print("Expense is exactly one week after the inputted date.")
                            expense.date = Date.now
                            expense.runningTotal = expense.runningTotal + expense.price
                            try? moc.save()
                            
                        } else {
                            print("Expense is not one week after the inputted date.")
                        }
                    }
                } else if timeFrame == "Monthly" {
                    if let oneMonthAfterExpenseDate = calendar.date(byAdding: .month, value: 1, to: expenseDate!) {
                        if calendar.isDate(currentDate, inSameDayAs: oneMonthAfterExpenseDate) {
                            print("Expense is month after input")
                            expense.date = Date.now
                            expense.runningTotal = expense.runningTotal + expense.price
                            try? moc.save()
                        } else {
                            print("Expens is not one month after the inputted date.")
                        }
                    }
                } else if timeFrame == "Yearly" {
                    if let oneYearAfterExpenseDate = calendar.date(byAdding: .year, value: 1, to: expenseDate!) {
                        if calendar.isDate(currentDate, inSameDayAs: oneYearAfterExpenseDate) {
                            print("Expense is a year after the inputted date.")
                            expense.date = Date.now
                            expense.runningTotal = expense.runningTotal + expense.price
                            try? moc.save()
                        } else {
                            print("Expense is not a year after the inputted date.")
                        }
                    }
                }
            }
        }
    }
    
    
    
    func modifyPriceForView(price:Double) -> String {
        return String(format: "%.2f", price)
    }
    
    func totalExpenses() -> Double {
        var total = 0.0
        for expense in expenses {
            total += expense.runningTotal
        }
        return total
    }
    func totalIncoming() -> Double {
        var total = 0.0
        for income in incomingE {
            total += income.runningTotal
        }
        for income in incomingO {
            total += income.amount
            
        }
        
        for income in incomingInv {
            total += income.dividend
            total += income.capitalGains
        }
        return total
    }
    
    func totalCombined() -> Double {
        let ex = totalExpenses()
        let inc = totalIncoming()
        
        return round(inc - ex)
    }
    
    func getDatesOrdered() -> Array<Any> {
        var res: Array<Any> = []
        
        for income in incomingE {
            res.append(income)
        }
        for income in incomingO {
            res.append(income)
        }
        
        for income in incomingInv {
            res.append(income)
        }
        
        for expense in expenses {
            res.append(expense)
        }
        res.sort {
            // Safely unwrap the date properties and compare
            guard let firstDate = ($0 as AnyObject).value(forKey: "date") as? Date,
                  let secondDate = ($1 as AnyObject).value(forKey: "date") as? Date else {
                return false
            }
            return firstDate < secondDate
        }
        print(res)
        return res
    }
    
    func getLatestOut() -> Double {
        var latestDate: Date? = nil
        var scoreForDate: Double = 0.0
        
        for expense in expenses.sorted(by: { $0.date ?? Date.distantPast > $1.date ?? Date.distantPast }) { // Sort incomes by descending date (handling nil dates)
            if let expenseDate = expense.date { // Optional binding for income.date
                if expenseDate > latestDate ?? Date.distantPast { // Use latestDate or a future date if nil
                    latestDate = expenseDate
                    scoreForDate = expense.price
                }
            }
        }
        //print(latestDate)
        //print(round(scoreForDate))
        return round(scoreForDate * 100) / 100.0
    }
    
    func getLatestIn() -> Double {
        var latestDate: Date? = nil
        var scoreForDate: Double = 0.0
        for income in incomingE.sorted(by: { $0.date ?? Date.distantPast > $1.date ?? Date.distantPast }) { // Sort incomes by descending date (handling nil dates)
            if let incomeDate = income.date { // Optional binding for income.date
                if incomeDate > latestDate ?? Date.distantPast { // Use latestDate or a future date if nil
                    latestDate = incomeDate
                    scoreForDate = income.salary
                }
            }
        }
        for income in incomingO.sorted(by: { $0.date ?? Date.distantPast > $1.date ?? Date.distantPast }) { // Sort incomes by descending date (handling nil dates)
            if let incomeDate = income.date { // Optional binding for income.date
                if incomeDate > latestDate ?? Date.distantPast { // Use latestDate or a future date if nil
                    latestDate = incomeDate
                    scoreForDate = income.amount
                }
            }
        }
        
        for income in incomingInv.sorted(by: { $0.date ?? Date.distantPast > $1.date ?? Date.distantPast }) { // Sort incomes by descending date (handling nil dates)
            if let incomeDate = income.date { // Optional binding for income.date
                if incomeDate > latestDate ?? Date.distantPast { // Use latestDate or a future date if nil
                    latestDate = incomeDate
                    scoreForDate = income.dividend
                }
            }
        }
        return round(scoreForDate * 100) / 100.0
    }
    
    
    
    
    
    func removeIncomeEmployment(at offsets: IndexSet) {
        for index in offsets {
            let income = incomingE[index]
            moc.delete(income)
        }
        do {
            try moc.save()
        } catch {
            // handle the Core Data error
        }
    }
    func removeIncomeInvestment(at offsets: IndexSet) {
        for index in offsets {
            let income = incomingInv[index]
            moc.delete(income)
        }
        do {
            try moc.save()
        } catch {
            // handle the Core Data error
        }
    }
    func removeIncomeOther(at offsets: IndexSet) {
        for index in offsets {
            let income = incomingO[index]
            moc.delete(income)
        }
        do {
            try moc.save()
        } catch {
            // handle the Core Data error
        }
    }
    
    func removeExpense(at offsets: IndexSet) {
        for index in offsets {
            let expense = expenses[index]
            moc.delete(expense)
        }
        do {
            try moc.save()
        } catch {
            // handle the Core Data error
        }
    }
}

    

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

