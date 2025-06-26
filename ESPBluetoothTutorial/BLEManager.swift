//
//  BLEManager.swift
//  ESPBluetoothTutorial
//
//  Created by Jackson Dugan on 6/26/25.
//

import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = BLEManager()
    
    @Published var isConnected = false
    @Published var discoveredPeripherals: [CBPeripheral] = []

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var controlCharacteristic: CBCharacteristic?
    
    let serviceUUID = CBUUID(string: "12345678-1234-5678-1234-56789abcdef0") // Update with actual
    let characteristicUUID = CBUUID(string: "abcd1234-5678-1234-5678-abcdef012345") // Update with actual

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Public BLE Actions

    func startScanning() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [serviceUUID])
            print("🔍 Scanning for peripherals...")
        }
    }

    func connect(to peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }

    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        isConnected = false
        connectedPeripheral = nil
        controlCharacteristic = nil
        print("🔌 Disconnected")
    }

    func sendValue(_ value: Int) {
        guard let peripheral = connectedPeripheral,
              let characteristic = controlCharacteristic else {
            print("❌ Not ready to send data")
            return
        }

        let command = "\(value)"
        if let data = command.data(using: .utf8) {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
            print("📤 Sent: \(command)")
        }
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            print("❌ Bluetooth not available")
            isConnected = false
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append(peripheral)
            print("📡 Discovered: \(peripheral.name ?? "Unknown")")
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        print("✅ Connected")
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        isConnected = false
        print("🔄 Disconnected. Scanning again...")
        startScanning()
    }

    // MARK: - CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == serviceUUID {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics where characteristic.uuid == characteristicUUID {
            controlCharacteristic = characteristic
            print("✅ Found characteristic")
        }
    }
    
    func refreshScan() {
        print("🔄 Pull-to-refresh BLE scan")
        discoveredPeripherals.removeAll()
        if centralManager.state == .poweredOn {
            centralManager.stopScan()
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        }
    }
}
