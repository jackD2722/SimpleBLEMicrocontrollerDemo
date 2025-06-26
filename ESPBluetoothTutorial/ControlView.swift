//
//  ControlView.swift
//  ESPBluetoothTutorial
//
//  Created by Jackson Dugan on 6/26/25.
//

import SwiftUI

struct ControlView: View {
    @ObservedObject var bleManager = BLEManager.shared
    @Binding var showControlView: Bool
    @State private var value: Double = 50

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    bleManager.disconnect()
                    showControlView = false
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .padding()
                }
                Spacer()
            }

            Text("BLE Slider Demo")
                .font(.title)
                .bold()

            Text(bleManager.isConnected ? "✅ Connected" : "❌ Not Connected")
                .foregroundColor(bleManager.isConnected ? .green : .red)

            Slider(value: $value, in: 1...100, step: 1) {
                Text("Value")
            } minimumValueLabel: {
                Text("1")
            } maximumValueLabel: {
                Text("100")
            }
            .padding(.horizontal)
            .onChange(of: value) {
                bleManager.sendValue(Int(value))
            }


            Text("Value: \(Int(value))")
                .font(.headline)
        }
        .padding()
    }
}
