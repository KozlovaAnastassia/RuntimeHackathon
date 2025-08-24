//
//  Models.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import Foundation

enum ClubCategory: String, CaseIterable, Codable, Hashable {
    case book = "Книжный"
    case sport = "Спортивный"
    case language = "Изучение языков"
    case art = "Творческий"
    case tech = "Технологии"
}
