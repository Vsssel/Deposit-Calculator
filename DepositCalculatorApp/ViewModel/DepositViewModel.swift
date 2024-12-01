//
//  DepositViewModel.swift
//  DepositCalculatorApp
//
//  Created by Assel Artykbay on 01.12.2024.
//

import Foundation

class DepositViewModel {
    var deposit: Deposit?
    var interestRate: Double = 14.0

    func configureDeposit(amount: Double, term: Int, currency: String, monthlyReplenishment: Double? = nil) {
        self.deposit = Deposit(amount: amount, term: term, currency: currency, monthlyReplenishment: monthlyReplenishment ?? 0.0)
        switch currency {
        case "Tenge":
            interestRate = 14.0
        case "Dollar USA":
            interestRate = 1.0
        default:
            interestRate = 0.0
        }
    }

    func getTotalReturn() -> (totalAmount: Double, interestEarned: Double, ownFunds: Double) {
        guard let deposit = deposit else { return (0.0, 0.0, 0.0) }
        
        let P = deposit.amount
        let r = (interestRate / 100) / 12
        let t = Double(deposit.term)
        let M = deposit.monthlyReplenishment

        let principalWithInterest = P * pow(1 + r, t)
        
        var replenishmentInterest: Double = 0.0
        for month in 1...deposit.term {
            let monthsRemaining = Double(deposit.term - month) 
            replenishmentInterest += M * pow(1 + r, monthsRemaining)
        }
        
        let ownFunds = P + M * t
        
        let totalAmount = principalWithInterest + replenishmentInterest
        
        let interestEarned = totalAmount - ownFunds
        
        return (
            totalAmount: round(totalAmount * 100) / 100,
            interestEarned: round(interestEarned * 100) / 100,
            ownFunds: round(ownFunds * 100) / 100
        )
    }

}
