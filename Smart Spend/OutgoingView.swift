//
//  OutgoingView.swift
//  Smart Spend
//
//  Created by Edward Jermyn on 09/05/2024.
//

import SwiftUI 

struct OutgoingView: View {
    @FetchRequest(sortDescriptors: []) var expenses: FetchedResults<Outgoing>
    @State private var showingSelectedExpenseView = false
    @State private var selectedExpense: Outgoing? = nil
    @Environment(\.managedObjectContext) var moc
    @AppStorage("selectedCurrencySymbol") private var selectedCurrencySymbol: String = "£"


    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(expenses) { expense in
                        NavigationLink(destination: SelectedExpenseView(expense: expense)) {
                            Text("\(expense.title ?? "Unknown"): \(selectedCurrencySymbol)\(modifyPriceForView(price: expense.price))")
                                .foregroundColor(.red)
                        }
                    }
                    .onDelete(perform: removeExpense)
                }
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddExpenseView()) {
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
    OutgoingView()
}


