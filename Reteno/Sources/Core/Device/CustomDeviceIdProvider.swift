import Foundation

public class CustomDeviceIdProvider: DeviceIdProvider {
    private var completion: ((String) -> Void)?
    
    public func setDeviceId(_ deviceId: String) {
        completion?(deviceId)
    }
    
    func setDeviceIdCompletionHandler(_ completion: @escaping (String) -> Void) {
        self.completion = completion
    }
}
