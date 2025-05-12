//
//  SessionType.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//


import Foundation

enum SessionType: String, Codable {
    case sauna = "Sauna"
    case coldPlunge = "Cold Plunge"
}

extension SessionType {
    var displayName: String {
        rawValue
    }
}
