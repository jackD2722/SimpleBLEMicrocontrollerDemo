//
//  ContentView.swift
//  ESPBluetoothTutorial
//
//  Created by Jackson Dugan on 6/26/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isConnected = false
    @State private var showControlView = false

    var body: some View {
        NavigationStack {
            if showControlView {
                ControlView(showControlView: $showControlView)
            } else {
                BLEScanView(isConnected: $isConnected, showControlView: $showControlView)
            }
        }
        .onChange(of: isConnected) {
            showControlView = isConnected
        }

    }
}
