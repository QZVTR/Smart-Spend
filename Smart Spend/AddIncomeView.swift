//
//  AddIncomeView.swift
//  Smart Spend
//
//  Created by Edward Jermyn on 18/05/2024.
//

import SwiftUI
import CoreData
import Foundation

struct AddIncomeView: View {
    @Environment(\.managedObjectContext) var moc
    @AppStorage("selectedCurrencySymbol") private var selectedCurrencySymbol: String = "£"

    @State private var selectedIncomeType = "Employment"
    @State private var incomeType = ["Employment", "Investment", "Other"]
    @State private var salary:Double = 0.0
    @State private var wakeUp = Date.now
    
    
    @State private var dividend: Double = 0.0
    @State private var capitalGains: Double = 0.0
    @State private var investmentName: String = ""
    
    @State private var nameOfIncome: String = ""
    @State private var freelance:Double = 0.0

  var body: some View {
    VStack {
      HStack {
        ForEach(incomeType, id: \.self) { incomeType in
          Text(incomeType)
            .foregroundColor(selectedIncomeType == incomeType ? .black.opacity(0.8) : .gray)
            .underline(selectedIncomeType == incomeType)
            .onTapGesture {
              selectedIncomeType = incomeType
            }
            .padding(.horizontal)
        }
      }

      Form {
        if selectedIncomeType == "Employment" {
          Text("Employment Form")

          Section {
            HStack {
              Text("Salary Per Month \(selectedCurrencySymbol):")
              TextField("", value: $salary, format: .number)
                .keyboardType(.decimalPad)
            }
          }

          Section {
            VStack {
              Text("What date do you receive your salary?")
              DatePicker("Please enter a date", selection: $wakeUp)
                .labelsHidden()
            }
          }

          Section {
            Button {
                saveEmployment(salary: salary, date: wakeUp)
            } label: {
              Text("Save")
            }
          }

        } else if selectedIncomeType == "Investment" {
            
            Text("Investment Form")
            Section {
                TextField("Enter name of investment", text: $investmentName)
            }
                Section {
                    HStack {
                        Text("Dividend \(selectedCurrencySymbol):")
                        TextField("", value: $dividend, format: .number)
                          .keyboardType(.decimalPad)
                    }
                }
                Section {
                    HStack {
                        Text("Capital Gains \(selectedCurrencySymbol):")
                        TextField("", value: $capitalGains, format: .number)
                          .keyboardType(.decimalPad)
                    }
                }
                Section {
                    Button {
                        saveInvestment(dividend: dividend, capitalGains: capitalGains, name: investmentName)
                    } label: {
                      Text("Save")
                    }
                }
          
        } else if selectedIncomeType == "Other" {
   
            Text("Other Income Form")
            Section {
                HStack {
                    TextField("Enter Name of Income", text: $nameOfIncome)
                }
            }
              Section {
                  HStack {
                      Text("Enter Amount \(selectedCurrencySymbol):")
                      TextField("", value: $freelance, format: .number)
                        .keyboardType(.decimalPad)
                  }
              }
              
              Section {
                  Button {
                      saveOther(title: nameOfIncome, amount: freelance)
                  } label: {
                    Text("Save")
                  }
              }
          
        }
      }
    }
  }
    
    
    func saveEmployment(salary: Double, date: Date) {
          
        let uuid = UUID()
              
        let incoming = Eincoming(context: moc) // Assuming EmploymentIncoming is the correct entity
        incoming.id = uuid
        incoming.salary = salary
        incoming.date = date
        incoming.runningTotal = salary
              
        do {
            try moc.save()
            print("Data Saved Successfully")
        } catch {
            print("Error When Saving \(error)")
        }
    }
    
    func saveInvestment(dividend: Double, capitalGains: Double, name: String) {
        let uuid = UUID()
        let invest = InvIncoming(context: moc)
        invest.id = uuid
        invest.dividend = dividend
        invest.capitalGains = capitalGains
        invest.name = name
        invest.date = Date.now
        invest.total = dividend + capitalGains
        
        do {
            try moc.save()
            print("Data Saved Successfully")
        } catch {
            print("Error When Saving \(error)")
        }
        
    }
    
    func saveOther(title: String, amount: Double) {
        let uuid = UUID()
        let other = OIncome(context: moc)
        other.id = uuid
        other.title = title
        other.amount = amount
        other.date = Date.now
        
        do {
            try moc.save()
            print("Data Saved Successfully")
        } catch {
            print("Error When Saving \(error)")
        }
    }

/*
func checkSalaryFormat(salary: Double) -> Bool {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 2

    let formattedPriceString = formatter.string(from: salary as NSNumber)
    return salary.description == formattedPriceString
    }
 */
    
    /*
    func netMonthlySalary(salaryPM: Double) -> Double {
        let annualSalary = salaryPM * 12
        // Constants
        let personalAllowance = 12570.0
        let basicRateLimit = 50270.0
        let higherRateLimit = 125140.0
        
        let basicRate = 0.20
        let higherRate = 0.40
        let additionalRate = 0.45
        
        // NIC thresholds
        let nicLowerThreshold = 1048.0 * 12 / 52 // Weekly £242 converted to monthly
        let nicUpperThreshold = 4189.0 * 12 / 52 // Weekly £967 converted to monthly
        
        let nicRateBasic = 0.12
        let nicRateHigher = 0.02
        
        // Monthly salary
        let grossMonthlySalary = annualSalary / 12.0
        
        // Taxable income
        let taxableIncome = max(0, annualSalary - personalAllowance)
        
        // Income tax calculation
        var annualIncomeTax = 0.0
        
        if taxableIncome > higherRateLimit {
            annualIncomeTax += (taxableIncome - higherRateLimit) * additionalRate
            annualIncomeTax += (higherRateLimit - basicRateLimit) * higherRate
            annualIncomeTax += (basicRateLimit - personalAllowance) * basicRate
        } else if taxableIncome > basicRateLimit {
            annualIncomeTax += (taxableIncome - basicRateLimit) * higherRate
            annualIncomeTax += (basicRateLimit - personalAllowance) * basicRate
        } else {
            annualIncomeTax += (taxableIncome - personalAllowance) * basicRate
        }
        
        let monthlyIncomeTax = annualIncomeTax / 12.0
        
        // National Insurance Contributions (NICs) calculation
        var monthlyNICs = 0.0
        
        if grossMonthlySalary > nicUpperThreshold {
            monthlyNICs += (grossMonthlySalary - nicUpperThreshold) * nicRateHigher
            monthlyNICs += (nicUpperThreshold - nicLowerThreshold) * nicRateBasic
        } else if grossMonthlySalary > nicLowerThreshold {
            monthlyNICs += (grossMonthlySalary - nicLowerThreshold) * nicRateBasic
        }
        
        // Net monthly salary calculation
        let netMonthlySalary = grossMonthlySalary - monthlyIncomeTax - monthlyNICs
        print(netMonthlySalary)
        return round(netMonthlySalary * 100) / 100
    }
     */
}

#Preview {
    AddIncomeView()
}
