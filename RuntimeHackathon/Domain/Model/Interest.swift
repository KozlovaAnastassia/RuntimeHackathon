//
//  Models.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import Foundation

struct Interest: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    let category: InterestCategory
}
