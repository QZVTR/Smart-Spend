//
//  AddExpenseView.swift
//  Smart Spend
//
//  Created by Edward Jermyn on 09/05/2024.
//

import SwiftUI
import CoreData
import Foundation

struct AddExpenseView: View {
    @State private var recurring = false
    @State private var selectedTimeFrame = "Weekly"

    @State private var title = ""
    @State private var price: Double = 0.0
    @Environment(\.managedObjectContext) var moc
    @AppStorage("selectedCurrencySymbol") private var selectedCurrencySymbol: String = "£"
    
    let timeFrame = ["Weekly", "Monthly", "Annually"]
    
    
    
    var body: some View {
        VStack {

            Form {
                Section {
                    TextField("Enter a name of expense", text: $title)
                }
                
                Toggle(isOn: $recurring) {
                    Text("Recurring Expense")
                }
                if recurring { // Only show picker if recurring is true
                    
                    Section {
                        Picker("Time Frame", selection: $selectedTimeFrame) {
                            ForEach(timeFrame, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                }
                Section {
                    HStack {
                        Text(selectedCurrencySymbol)
                        TextField("", value: $price, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }
                Section {
                    Button {
                        saveData(name: title, reoccur: recurring, TimeFrame: selectedTimeFrame,price: price)
                    } label: {
                        Text("Save")
                    }
                }
            }
            .navigationTitle("Expense Form")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    

    
    
    func saveData(name: String, reoccur: Bool, TimeFrame: String, price: Double) {
        
        let uuid = UUID()

            // Access the UUID string representation
            //let uuidString = uuid.uuidString
        var updatedTimeFrame: String

        if reoccur == false {
            updatedTimeFrame = ""
        } else {
            updatedTimeFrame = TimeFrame
        }
        let expense = Outgoing(context: moc)
        expense.id = uuid
        expense.title = name
        expense.reoccur = reoccur
        
        expense.updatedTimeFrame = updatedTimeFrame
    
        expense.price = price
        expense.date = Date.now
        expense.runningTotal = price
        do {
            try moc.save()
            print("Data Saved Successfully")
        } catch {
            print("Error When Saving \(error)")
        }
    }
    
    func checkPriceFormat(price: Double) -> Bool {
      let formatter = NumberFormatter()
      formatter.numberStyle = .decimal
      formatter.minimumFractionDigits = 1
      formatter.maximumFractionDigits = 2

      let formattedPriceString = formatter.string(from: price as NSNumber)
      return price.description == formattedPriceString
    }

}





#Preview {
    AddExpenseView()
}




