//
//  NavStackCompat.swift
//  SimpleX (iOS)
//
//  Created by Evgeny on 23/01/2023.
//  Copyright © 2023 SimpleX Chat. All rights reserved.
//

import SwiftUI

struct NavStackCompat <C: View, D: View>: View {
    let isActive: Binding<Bool>
    let destination: () -> D
    let content: () -> C
    @State private var path: [Bool]

    init(isActive: Binding<Bool>, destination: @escaping () -> D, content: @escaping () -> C) {
        self.isActive = isActive
        self.destination = destination
        self.content = content
        _path = State(initialValue: isActive.wrappedValue ? [true] : [])
    }

    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack(path: $path) {
                ZStack {
                    NavigationLink(value: true) { EmptyView() }
                    content()
                }
                .navigationDestination(for: Bool.self) { show in
                    if show { destination() }
                }
            }
            .onChange(of: isActive.wrappedValue) { active in
                if active {
                    if path.isEmpty { path = [true] }
                } else if !path.isEmpty { path = [] }
            }
            .onChange(of: path.isEmpty) { empty in
                if empty && isActive.wrappedValue { isActive.wrappedValue = false }
            }
        } else {
            NavigationView {
                ZStack {
                    NavigationLink(
                        destination: destination(),
                        isActive: isActive
                    ) { EmptyView() }
                    content()
                }
            }
            .navigationViewStyle(.stack)
        }
    }
}
