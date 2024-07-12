//
//  SelectedIncomeInvestment.swift
//  Smart Spend
//
//  Created by Edward Jermyn on 27/05/2024.
//


/*
Included:
date
id
name
capital gains
dividend
*/

import SwiftUI

struct SelectedIncomeInvestment: View {
    let income: InvIncoming?
    var body: some View {
        VStack {
            if let income = income {
                Text("Investment Details:")
                Text("Title: \(income.name ?? "Unknown")")
                // Display expense details using expense.id, expense.title, etc.
                Text("Capital Gains: £\(modifyPriceForView(price:income.capitalGains))")
                Text("ID: \(income.id ?? UUID())")
                Text("Dividend: £\(modifyPriceForView(price: income.dividend))")
                
                
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
    SelectedIncomeInvestment()
}
*/
