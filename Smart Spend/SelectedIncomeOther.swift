//
//  SelectedIncomeOther.swift
//  Smart Spend
//
//  Created by Edward Jermyn on 27/05/2024.
//

/*
Included:
date
id
amount
title
*/

import SwiftUI

struct SelectedIncomeOther: View {
    let income: OIncome?
    var body: some View {
        VStack {
            if let income = income {
                Text("Other Income Type Details:")
                Text("Title: \(income.title ?? "Unknown")")
                // Display expense details using expense.id, expense.title, etc.
                Text("Amount: \(modifyPriceForView(price:income.amount))")
                Text("ID: \(income.id ?? UUID())")
                
                
                
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
    SelectedIncomeOther()
}
*/
