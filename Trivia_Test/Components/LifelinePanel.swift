//
//  LifelinePanel.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//



import SwiftUI

struct LifelinePanel: View {
    @ObservedObject var presenter: GamePresenter
    let onUseLifeline: (LifelineType) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(LifelineType.allCases, id: \.self) { type in
                LifelineButton(
                    lifeline: type,
                    quantity: presenter.getLifelineQuantity(type),
                    isDisabled: presenter.showingAnswer || presenter.needsToWatchAd,
                    action: { onUseLifeline(type) }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.dynamicCardBackground.opacity(colorScheme == .dark ? 0.8 : 0.95))
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 5)
        )
    }
}
