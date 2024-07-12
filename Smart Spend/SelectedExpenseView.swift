//
//  SelectedExpenseView.swift
//  Smart Spend
//
//  Created by Edward Jermyn on 17/05/2024.
//

import SwiftUI

struct SelectedExpenseView: View {
    
    
    let expense: Outgoing?
    @AppStorage("selectedCurrencySymbol") private var selectedCurrencySymbol: String = "£"
    
    var body: some View {
        VStack {
            if let expense = expense {
                Text("Expense Details:")
                // Display expense details using expense.id, expense.title, etc.
                Text("Title: \(expense.title ?? "Unknown")")
                Text("ID: \(expense.id ?? UUID())")
                Text("Price: \(selectedCurrencySymbol)\(modifyPriceForView(price: expense.price))")
                Text("Date Added: \(expense.date ?? Date.now)")
                
              } else {
                Text("No Expense Selected")
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
    SelectedExpenseView(expense: expense?)
}
*/
