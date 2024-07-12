//
//  ProfileView.swift
//  Smart Spend
//
//  Created by Edward Jermyn on 09/05/2024.
//
import SwiftUI
import Charts

struct ProfileView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var incomingE: FetchedResults<Eincoming>
    @FetchRequest(sortDescriptors: []) var incomingInv: FetchedResults<InvIncoming>
    @FetchRequest(sortDescriptors: []) var incomingO: FetchedResults<OIncome>
    @FetchRequest(sortDescriptors: []) var expenses: FetchedResults<Outgoing>
    
    @State private var currencies = ["GBP", "USD", "EUR", "AUD", "CAD"]
    @State private var currencySymbols: [String: String] = [
        "GBP": "£",
        "USD": "$",
        "EUR": "€",
        "AUD": "A$",
        "CAD": "C$"
    ]
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "GBP"
    @AppStorage("selectedCurrencySymbol") private var selectedCurrencySymbol: String = "£"

    var yearlyExpenses: [YearExpense] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses, by: { calendar.component(.year, from: $0.date!) })
        return grouped.map { YearExpense(year: $0.key, total: $0.value.reduce(0) { $0 + $1.price }) }
    }

    var monthlyExpenses: [MonthExpense] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses, by: { calendar.dateComponents([.year, .month], from: $0.date!) })
        return grouped.map { MonthExpense(year: $0.key.year!, month: $0.key.month!, total: $0.value.reduce(0) { $0 + $1.price }) }
    }

    var dailyExpenses: [DayExpense] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses, by: { calendar.startOfDay(for: $0.date!) })
        return grouped.map { DayExpense(date: $0.key, total: $0.value.reduce(0) { $0 + $1.price }) }
            .filter { $0.date >= calendar.date(byAdding: .day, value: -7, to: Date())! }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Section {
                    Text("Monthly Expenses")
                        .font(.headline)
                    Chart(monthlyExpenses) { item in
                        BarMark(
                            x: .value("Month", "\(item.year)-\(item.month)"),
                            y: .value("Total", item.total)
                        )
                        .cornerRadius(5)
                        .foregroundStyle(Color.red)
                    }
                    .frame(height: 200)

                    Text("Daily Expenses")
                        .font(.headline)
                    Chart(dailyExpenses) { item in
                        BarMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Total", item.total)
                        )
                        .cornerRadius(5)
                        .foregroundStyle(Color.red)
                    }
                    .frame(height: 200)
                }
                Section {
                    Picker("Please choose a currency", selection: $selectedCurrency) {
                        ForEach(currencies, id: \.self) {
                            Text($0)
                        }
                    }
                    .onChange(of: selectedCurrency) {
                        selectedCurrencySymbol = currencySymbols[$0] ?? ""
                    }
                    Text("You selected: \(selectedCurrency) (\(selectedCurrencySymbol))")
                }

                Section {
                    NavigationLink {
                        ReportsView()
                    } label: {
                        Text("View Reports")
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                }
            }
            .onAppear {
                if selectedCurrencySymbol.isEmpty {
                    selectedCurrencySymbol = currencySymbols[selectedCurrency] ?? ""
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct YearExpense: Identifiable {
    var id: Int { year }
    let year: Int
    let total: Double
}

struct MonthExpense: Identifiable {
    var id: String { "\(year)-\(month)" }
    let year: Int
    let month: Int
    let total: Double
}

struct DayExpense: Identifiable {
    var id: Date { date }
    let date: Date
    let total: Double
}

#Preview {
    ProfileView()
}
