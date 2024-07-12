//
//  SelectedIncomeSalary.swift
//  Smart Spend
//
//  Created by Edward Jermyn on 27/05/2024.
//

/*
Included:
date
id
salary
runningTotal
*/

import SwiftUI

struct SelectedIncomeSalary: View {
    let income: Eincoming?
    
    var body: some View {
        VStack {
            if let income = income {
                Text("Expense Details:")
                // Display expense details using expense.id, expense.title, etc.
                Text("Salary Per Month: \(modifyPriceForView(price:income.salary))")
                Text("ID: \(income.id ?? UUID())")
                Text("Price: £\(modifyPriceForView(price: income.runningTotal))")
                
                
              } else {
                Text("No Salary Selected")
              }
        }
        .containerRelativeFrame([.horizontal, .vertical])
        .background(Gradient(colors: [.teal, .cyan, .green]).opacity(0.6))
    }
    
    
    func modifyPriceForView(price:Double) -> String {
        return String(format: "%.2f", price)
    }
}
/*
#Preview {
    SelectedIncomeSalary()
}
 */
