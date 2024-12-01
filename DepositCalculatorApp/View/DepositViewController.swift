//
//  DepositViewController.swift
//  DepositCalculatorApp
//
//  Created by Assel Artykbay on 01.12.2024.
//

import UIKit
import SnapKit

class DepositViewController: UIViewController, UITableViewDataSource {
    private let amountTextField = UITextField()
    private let replenishmentTextField = UITextField()
    private let termSegmentControl = UISegmentedControl(items: ["3 mon", "6 mon", "12 mon"])
    private let currencySegmentedControl = UISegmentedControl(items: ["Tenge", "Dollar USA"])
    private let resultTableView = UITableView()
    
    private let viewModel = DepositViewModel()
    private var resultData: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        inputsChanged()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Deposit Calculator"
        
        amountTextField.placeholder = "Enter deposit amount"
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .numberPad
        amountTextField.addTarget(self, action: #selector(inputsChanged), for: .editingChanged)
        view.addSubview(amountTextField)
        
        replenishmentTextField.placeholder = "Enter monthly replenishment"
        replenishmentTextField.borderStyle = .roundedRect
        replenishmentTextField.keyboardType = .numberPad
        replenishmentTextField.addTarget(self, action: #selector(inputsChanged), for: .editingChanged)
        view.addSubview(replenishmentTextField)
        
        termSegmentControl.selectedSegmentIndex = 0
        termSegmentControl.addTarget(self, action: #selector(inputsChanged), for: .valueChanged)
        view.addSubview(termSegmentControl)
        
        currencySegmentedControl.selectedSegmentIndex = 0
        currencySegmentedControl.addTarget(self, action: #selector(inputsChanged), for: .valueChanged)
        view.addSubview(currencySegmentedControl)
                
        resultTableView.dataSource = self
        resultTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResultCell")
        view.addSubview(resultTableView)
        
        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        replenishmentTextField.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        termSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(replenishmentTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        currencySegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(termSegmentControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }
        
        resultTableView.snp.makeConstraints { make in
            make.top.equalTo(currencySegmentedControl.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
    
    private func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        resultTableView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        resultTableView.addGestureRecognizer(swipeRight)
    }
    
    @objc private func inputsChanged() {
        let amountText = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let termText = termSegmentControl.titleForSegment(at: termSegmentControl.selectedSegmentIndex)
        let selectedCurrency = currencySegmentedControl.titleForSegment(at: currencySegmentedControl.selectedSegmentIndex) ?? "Tenge"
        let replenishmentText = replenishmentTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Default to zero if amount is empty
        let amount = Double(amountText ?? "") ?? 0.0
        let term = Int(termText?.replacingOccurrences(of: " mon", with: "") ?? "3") ?? 3
        let replenishment = Double(replenishmentText ?? "") ?? 0.0
        
        viewModel.configureDeposit(amount: amount, term: term, currency: selectedCurrency, monthlyReplenishment: replenishment)
        
        // Calculate and update the result data
        let totalReturn = viewModel.getTotalReturn()
        resultData = [
            "Deposit Amount: \(amount) \(selectedCurrency)",
            "Deposit Term: \(term) months",
            "Interest Rate: \(viewModel.interestRate)%",
            "Monthly Replenishment: \(replenishment) \(selectedCurrency)",
            "Total Return: \(totalReturn.totalAmount) \(selectedCurrency)",
            "Interest Earned: \(totalReturn.interestEarned) \(selectedCurrency)",
            "Own Funds: \(totalReturn.ownFunds) \(selectedCurrency)"
        ]
        resultTableView.reloadData()
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let initialFrame = resultTableView.frame
        let directionMultiplier: CGFloat = gesture.direction == .left ? -0.5 : 0.5
        let offScreenFrame = CGRect(
            x: initialFrame.origin.x + directionMultiplier * initialFrame.width,
            y: initialFrame.origin.y,
            width: initialFrame.width,
            height: initialFrame.height
        )
        
        UIView.animate(withDuration: 0.3, animations: {
            self.resultTableView.frame = offScreenFrame
            self.resultTableView.alpha = 0
        }, completion: { _ in
            if gesture.direction == .left {
                self.currencySegmentedControl.selectedSegmentIndex = 1
            } else if gesture.direction == .right {
                self.currencySegmentedControl.selectedSegmentIndex = 0
            }
            self.inputsChanged()
            
            self.resultTableView.frame = CGRect(
                x: initialFrame.origin.x - directionMultiplier * initialFrame.width,
                y: initialFrame.origin.y,
                width: initialFrame.width,
                height: initialFrame.height
            )
            UIView.animate(withDuration: 0.3) {
                self.resultTableView.frame = initialFrame
                self.resultTableView.alpha = 0.5
            }
        })
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        cell.textLabel?.text = resultData[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
