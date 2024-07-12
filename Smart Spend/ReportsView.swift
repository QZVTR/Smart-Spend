//
//  ReportsView.swift
//  Smart Spend
//
//  Created by Edward Jermyn on 28/05/2024.
//

import SwiftUI
import CoreData
import Foundation 

struct ReportsView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var incomingE: FetchedResults<Eincoming>
    @FetchRequest(sortDescriptors: []) var incomingInv: FetchedResults<InvIncoming>
    @FetchRequest(sortDescriptors: []) var incomingO: FetchedResults<OIncome>
    @FetchRequest(sortDescriptors: []) var expenses: FetchedResults<Outgoing>
    @FetchRequest(sortDescriptors: []) var reports: FetchedResults<Report>
    @State private var lastReportDate: Date? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                if reports.isEmpty {
                    Text("No Reports Yet")
                } else {
                    List {
                        ForEach(reports) { report in
                            NavigationLink {
                                SelectedReportView(report: report)
                            } label: {
                                HStack {
                                    Text("Report \(getMonth(fullDate: report.date ?? Date()))")
                                    Image(systemName: "book.pages")
                                }
                            }
                        }
                        .onDelete(perform: removeReport)
                    }
                }
            }
        }
        .navigationTitle("Financial Reports")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkAndGenerateReport()
            //generateReport()
        }
    }
    
    func getMonth(fullDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: fullDate)
    }
    
    func checkAndGenerateReport() {
        if let lastDate = UserDefaults.standard.object(forKey: "lastReportDate") as? Date {
            lastReportDate = lastDate
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        if let lastDate = lastReportDate {
            let lastMonth = calendar.component(.month, from: lastDate)
            let lastYear = calendar.component(.year, from: lastDate)
            
            if lastMonth == currentMonth && lastYear == currentYear {
                print("Report already generated for this month.")
                return
            }
        }
        
        generateReport()
        UserDefaults.standard.set(currentDate, forKey: "lastReportDate")
        lastReportDate = currentDate
    }
    
    func generateReport() {
        let currDate = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: currDate)
        
        if day == 1 {
            let total = totalCombined()
            let date = Date()
            let id = UUID()
            let monthlyExpenses = expenseData()
            let monthlyIncome = incomeData()
            let report = Report(context: moc)
            report.id = id
            report.date = date
            report.income = monthlyIncome
            report.expenses = monthlyExpenses
            report.total = total
            report.incomeTotal = totalIncoming()
            report.expenseTotal = totalExpenses()
            do {
                try moc.save()
                print("Data Saved Successfully")
            } catch {
                print("Error When Saving \(error)")
            }
        } else {
            print("Not first of month")
        }
    }
    
    func incomeData() -> String {
        var temp: [[String: Any]] = []
        let currDate = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: currDate)
        let dateFormatter = ISO8601DateFormatter()
        
        for income in incomingE {
            if let incomeDate = income.date {
                let incomeMonth = calendar.component(.month, from: incomeDate)
                if incomeMonth == month - 1 {
                    let incomeDict: [String: Any] = [
                        "id": income.id?.uuidString ?? UUID().uuidString,
                        "type": "Employment",
                        "salary": income.salary,
                        "date": dateFormatter.string(from: incomeDate),
                        "running total": income.runningTotal
                    ]
                    temp.append(incomeDict)
                }
            } else {
                print("Error: income.date is nil for income \(income)")
            }
        }
        
        for income in incomingInv {
            if let incomeDate = income.date {
                let incomeMonth = calendar.component(.month, from: incomeDate)
                if incomeMonth == month - 1 {
                    let incomeDict: [String: Any] = [
                        "id": income.id?.uuidString ?? UUID().uuidString,
                        "type": "Investment",
                        "title": income.name ?? "Unknown",
                        "date": dateFormatter.string(from: incomeDate),
                        "dividend": income.dividend,
                        "capital gains": income.capitalGains
                    ]
                    temp.append(incomeDict)
                }
            } else {
                print("Error: income.date is nil for income \(income)")
            }
        }
        
        for income in incomingO {
            if let incomeDate = income.date {
                let incomeMonth = calendar.component(.month, from: incomeDate)
                if incomeMonth == month - 1 {
                    let incomeDict: [String: Any] = [
                        "id": income.id?.uuidString ?? UUID().uuidString,
                        "type": "Other",
                        "amount": income.amount,
                        "date": dateFormatter.string(from: incomeDate),
                        "title": income.title ?? "Unknown"
                    ]
                    temp.append(incomeDict)
                }
            } else {
                print("Error: income.date is nil for income \(income)")
            }
        }
        
        return convertToJSONString(temp)
    }
    
    func expenseData() -> String {
        var temp: [[String: Any]] = []
        let currDate = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: currDate)
        let dateFormatter = ISO8601DateFormatter()
        
        for expense in expenses {
            if let expenseDate = expense.date {
                let expenseMonth = calendar.component(.month, from: expenseDate)
                if expenseMonth == month - 1 {
                    let expenseDict: [String: Any] = [
                        "id": expense.id?.uuidString ?? UUID().uuidString,
                        "title": expense.title ?? "Unknown Title",
                        "reoccur": expense.reoccur,
                        "timeFrame": expense.updatedTimeFrame ?? "Unknown Time Frame",
                        "price": expense.price,
                        "date": dateFormatter.string(from: expenseDate),
                        "runningTotal": expense.runningTotal
                    ]
                    temp.append(expenseDict)
                }
            } else {
                print("Error: expense.date is nil for expense \(expense)")
            }
        }
        
        return convertToJSONString(temp)
    }
    
    func convertToJSONString(_ array: [[String: Any]]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                return jsonString
            } else {
                print("Failed to convert JSON data to string")
                return "[]"
            }
        } catch {
            print("Failed to convert array to JSON string: \(error)")
            return "[]"
        }
    }
    
    func modifyPriceForView(price: Double) -> String {
        return String(format: "%.2f", price)
    }
    
    func totalExpenses() -> Double {
        return expenses.reduce(0) { $0 + $1.runningTotal }
    }
    
    func totalIncoming() -> Double {
        let employmentIncome = incomingE.reduce(0) { $0 + $1.runningTotal }
        let otherIncome = incomingO.reduce(0) { $0 + $1.amount }
        let investmentIncome = incomingInv.reduce(0) { $0 + $1.dividend + $1.capitalGains }
        return employmentIncome + otherIncome + investmentIncome
    }
    
    func totalCombined() -> Double {
        return round(totalIncoming() - totalExpenses())
    }
    
    func removeReport(at offsets: IndexSet) {
        for index in offsets {
            let report = reports[index]
            moc.delete(report)
        }
        do {
            try moc.save()
        } catch {
            print("Failed to delete report: \(error)")
        }
    }
}




#Preview {
    ReportsView()
}
