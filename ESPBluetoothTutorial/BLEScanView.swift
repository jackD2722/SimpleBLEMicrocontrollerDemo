//
//  BLEScanView.swift
//  ESPBluetoothTutorial
//
//  Created by Jackson Dugan on 6/26/25.
//

import SwiftUI

struct BLEScanView: View {
    @ObservedObject var bleManager = BLEManager.shared
    @Binding var isConnected: Bool
    @Binding var showControlView: Bool

    var body: some View {
        NavigationView {
            List {
                ForEach(bleManager.discoveredPeripherals, id: \.identifier) { peripheral in
                    Button(action: {
                        bleManager.connect(to: peripheral)
                    }) {
                        Text(peripheral.name ?? "Unnamed Device")
                    }
                }
            }
            .navigationTitle("Select a Device")
            .refreshable {
                bleManager.refreshScan()
            }
            .onAppear {
                bleManager.discoveredPeripherals.removeAll()
                bleManager.startScanning()
            }
            .onReceive(bleManager.$isConnected) { connected in
                isConnected = connected
            }
        }
    }
}
