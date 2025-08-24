//
//  TabBarButton.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import SwiftUI

struct TabBarButton: View {
    var index: Int
    var systemImage: String? = nil
    var assetImage: String? = nil
    var textKey: String
    @Binding var selectedTab: Int
    
    var body: some View {
        Button(action: {
            selectedTab = index
        }) {
            VStack {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 20))
                } else if let assetImage = assetImage {
                    Image(assetImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                Text(textKey).font(.caption)
            }
            .foregroundColor(selectedTab == index ? .orange : .gray)
        }
    }
}
