//
//  SelectedReportView.swift
//  Smart Spend
//
//  Created by Edward Jermyn on 28/05/2024.
//

import SwiftUI

struct SelectedReportView: View {
    let report: Report?
    @State private var expenseData: [[String: String]] = []
    @State private var incomeData: [[String: String]] = []
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "GBP"
    @AppStorage("selectedCurrencySymbol") private var selectedCurrencySymbol: String = "£"
    var body: some View {
        VStack {
            if let report = report {
                if report.incomeTotal > report.expenseTotal {
                    Text("Overall total income for the month: \(selectedCurrencySymbol)\(modifyPriceForView(price: report.total))")
                        .foregroundStyle(Color.green)
                } else if report.incomeTotal < report.expenseTotal {
                    Text("Overall Total for the month: \(selectedCurrencySymbol)\(modifyPriceForView(price: report.total))")
                        .foregroundStyle(Color.red)
                }
                Text("Currency: \(selectedCurrency)")
                // Display expenses data
                if !expenseData.isEmpty {
                    Text("Expenses:")
                    Text("Total Expenses: \(selectedCurrencySymbol)\(modifyPriceForView(price: report.expenseTotal))")
                    ForEach(expenseData.indices, id: \.self) { index in
                        ForEach(expenseData[index].sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            if key != "id" && key != "date" && key != "time" && key != "reoccur" && key != "timeFrame" && key != "runningTotal" {
                                Text("\(key.capitalized): \(value)")
                            }
                        }


                    }
                }
                // Display income data
                if !incomeData.isEmpty {
                    Text("Income:")
                    Text("Total Income: \(selectedCurrencySymbol)\(modifyPriceForView(price: report.incomeTotal))")
                    ForEach(incomeData.indices, id: \.self) { index in
                        ForEach(incomeData[index].sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            if key != "id" && key != "date" {
                                Text("\(key.capitalized): \(value)")
                            }
                        }
                    }
                }
            } else {
                Text("No Report Selected")
            }
        }
        .onAppear {
            if let jsonString = report?.expenses {
                expenseData = parseJSONString(jsonString: jsonString) ?? []
            }
            if let jsonString = report?.income {
                incomeData = parseJSONString(jsonString: jsonString) ?? []
            }
        }
        .navigationTitle("Report Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    func modifyPriceForView(price: Double) -> String {
        return String(format: "%.2f", price)
    }

    func parseJSONString(jsonString: String?) -> [[String: String]]? {
        guard let jsonString = jsonString else {
            print("JSON string is nil")
            return nil
        }
        // Convert the JSON string to Data
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Error converting JSON string to Data")
            return nil
        }

        do {
            // Deserialize the JSON data into an array of dictionaries
            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                var stringArray: [[String: String]] = []
                for dict in jsonArray {
                    var stringDict: [String: String] = [:]
                    for (key, value) in dict {
                        stringDict[key] = "\(value)"
                    }
                    stringArray.append(stringDict)
                }
                return stringArray
            }
        } catch {
            print("Error deserializing JSON: \(error)")
        }

        return nil
    }
}






/*
#Preview {
    SelectedReportView()
}
*/
