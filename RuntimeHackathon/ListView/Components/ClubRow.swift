//
//  ClubRow.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import SwiftUI

struct ClubRow: View {
    let club: Club
    let onJoin: () -> Void
    let onLeave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                HStack {
                    // Локальное изображение или SF Symbol
                    if let image = club.localImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 60)
                            .cornerRadius(8)
                            .padding(.trailing, 8)
                    } else {
                        Image(systemName: club.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding(.trailing, 8)
                            .foregroundColor(.blue)
                    }
                    
                    Text(club.name)
                        .font(.headline)
                    
                    Spacer()
                }
                .padding(.trailing, 8)
                
                if club.isCreator {
                    Text("Создатель клуба")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(10)
                        .padding(.top, 4)
                        .padding(.trailing, 4)
                }
            }
            
            HStack(spacing: 12) {
                if club.isJoined {
                    HStack {
                        Text("Участник")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 6)
                            .background(Color.orange)
                            .cornerRadius(12)
                            .transition(.scale.combined(with: .opacity))
                        
                        Spacer()
                        
                        Button(action: onLeave) {
                            Image(systemName: "rectangle.portrait.and.arrow.forward")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                } else {
                    Button(action: onJoin) {
                        Text("Вступить")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(club.isJoined ? Color.orange.opacity(0.2) : Color.gray.opacity(0.15))
        .cornerRadius(12)
        .padding(.horizontal)
        .animation(.spring(), value: club.isJoined)
    }
}
