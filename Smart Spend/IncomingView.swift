//
//  IncomingView.swift
//  Smart Spend
//
//  Created by Edward Jermyn on 09/05/2024.
//

import SwiftUI

struct IncomingView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Eincoming.entity(), sortDescriptors: []) var incomingE: FetchedResults<Eincoming>
    @FetchRequest(entity: InvIncoming.entity(), sortDescriptors: []) var incomingInv: FetchedResults<InvIncoming>
    @FetchRequest(entity: OIncome.entity(), sortDescriptors: []) var incomingO: FetchedResults<OIncome>
    @AppStorage("selectedCurrencySymbol") private var selectedCurrencySymbol: String = "£"
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(incomingE) { income in
                        NavigationLink(destination: SelectedIncomeSalary(income: income)) {
                            Text("Salary: \(selectedCurrencySymbol)\(modifyPriceForView(price: income.salary))")
                                .foregroundColor(.green)
                        }
                    }
                    .onDelete(perform: removeIncomeEmployment)
                    
                    ForEach(incomingInv) { income in
                        NavigationLink(destination: SelectedIncomeInvestment(income: income)) {
                            Text("\(income.name ?? "Unknown") Total: \(selectedCurrencySymbol)\(modifyPriceForView(price: income.total))")
                                .foregroundColor(.green)
                        }
                    }
                    .onDelete(perform: removeIncomeInvestment)
                    
                    ForEach(incomingO) { income in
                        NavigationLink(destination: SelectedIncomeOther(income: income)) {
                            Text("\(income.title ?? "Unknown Title"): \(selectedCurrencySymbol)\(modifyPriceForView(price: income.amount))")
                                .foregroundColor(.green)
                        }
                    }
                    .onDelete(perform: removeIncomeOther)
                }
            }
            .navigationTitle("Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddIncomeView()) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    func modifyPriceForView(price: Double) -> String {
        return String(format: "%.2f", price)
    }
    
    func removeIncomeEmployment(at offsets: IndexSet) {
        for index in offsets {
            let income = incomingE[index]
            moc.delete(income)
        }
        saveContext()
    }
    
    func removeIncomeInvestment(at offsets: IndexSet) {
        for index in offsets {
            let income = incomingInv[index]
            moc.delete(income)
        }
        saveContext()
    }
    
    func removeIncomeOther(at offsets: IndexSet) {
        for index in offsets {
            let income = incomingO[index]
            moc.delete(income)
        }
        saveContext()
    }
    
    private func saveContext() {
        do {
            try moc.save()
        } catch {
            // Handle the Core Data error appropriately
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}

#Preview {
    IncomingView()
}

