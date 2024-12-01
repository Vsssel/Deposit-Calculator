//
//  ConfigurableCell.swift
//  DepositCalculatorApp
//
//  Created by Assel Artykbay on 01.12.2024.
//

import Foundation
import UIKit

class ConfigurableCell: UITableViewCell {
    static let identifier = "ConfigurableCell"
    
    func configure(with model: CellModel) {
        textLabel?.text = model.title
        detailTextLabel?.text = model.subtitle
    }
}
