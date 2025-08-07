import SwiftUI

struct ControlView: View {
    @ObservedObject var bleManager = BLEManager.shared
    @Binding var showControlView: Bool
    @State private var steeringValue: Double = 90 // Default steering value
    @State private var throttleValue: Double = 90 // Default throttle value

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

            Text("BLE Dual Servo Demo")
                .font(.title)
                .bold()

            Text(bleManager.isConnected ? "✅ Connected" : "❌ Not Connected")
                .foregroundColor(bleManager.isConnected ? .green : .red)

            // Steering Slider
            Text("Steering")
                .font(.headline)
            Slider(value: $steeringValue, in: 50...130, step: 1) {
                Text("Steering")
            } minimumValueLabel: {
                Text("50")
            } maximumValueLabel: {
                Text("130")
            }
            .padding(.horizontal)
            .onChange(of: steeringValue) {
                bleManager.sendSteeringValue(Int(steeringValue))
            }
            Text("Steering Value: \(Int(steeringValue))")
                .font(.subheadline)

            // Throttle Slider
            Text("Throttle")
                .font(.headline)
            Slider(value: $throttleValue, in: 0...180, step: 1) {
                Text("Throttle")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("180")
            }
            .padding(.horizontal)
            .onChange(of: throttleValue) {
                bleManager.sendThrottleValue(Int(throttleValue))
            }
            Text("Throttle Value: \(Int(throttleValue))")
                .font(.subheadline)
        }
        .padding()
    }
}
