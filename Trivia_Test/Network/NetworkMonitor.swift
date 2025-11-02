import Network
internal import Combine

@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    @Published var connectionType: NWInterface.InterfaceType?
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let isConnected = path.status == .satisfied
            let connectionType = path.availableInterfaces.first?.type
            
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.isConnected = isConnected
                self.connectionType = connectionType
                
                if isConnected {
                    print("✅ Network connected")
                } else {
                    print("❌ Network disconnected")
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    nonisolated func stopMonitoring() {
        monitor.cancel()
    }
    
    deinit {
        stopMonitoring()
    }
}
