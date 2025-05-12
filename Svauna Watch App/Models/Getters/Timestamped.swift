//
//  Timestamped.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/30/25.
//

import Foundation

protocol Timestamped: Identifiable {
    var timestamp: Date { get }
}
