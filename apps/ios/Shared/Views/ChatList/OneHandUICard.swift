//
//  OneHandUICard.swift
//  SimpleX (iOS)
//
//  Created by EP on 06/08/2024.
//  Copyright © 2024 SimpleX Chat. All rights reserved.
//

import SwiftUI
import SimpleXChat

struct OneHandUICard: View {
    @AppStorage(GROUP_DEFAULT_ONE_HAND_UI, store: groupDefaults) private var oneHandUI = true
    @AppStorage(DEFAULT_ONE_HAND_UI_CARD_SHOWN) private var oneHandUICardShown = false
    @State private var showOneHandUIAlert = false

    var body: some View {
        HStack {
            Picker("Reachable chat toolbar", selection: $oneHandUI) {
                Text("Bottom bar").tag(true)
                Text("Top bar").tag(false)
            }
            .pickerStyle(.segmented)
            Button { showOneHandUIAlert = true } label: {
                Image(systemName: "xmark.circle")
            }
            .accessibilityLabel(Text("Close"))
        }
        .alert(isPresented: $showOneHandUIAlert) {
            Alert(
                title: Text("Reachable chat toolbar"),
                message: Text("You can change it in Appearance settings."),
                dismissButton: .default(Text("Ok")) {
                    withAnimation {
                        oneHandUICardShown = true
                    }
                }
            )
        }
    }


}

#Preview {
    OneHandUICard()
}
