import Foundation
import UIKit

class DefaultDeviceIdProvider: DeviceIdProvider {
    func setDeviceId(_ deviceId: String) {}
    
    func setDeviceIdCompletionHandler(_ completion: @escaping (String) -> Void) {
        if let deviceId = DeviceIdHelper.deviceId() {
            completion(deviceId)
        } else {
            completion(UIDevice.current.identifierForVendor?.uuidString ?? "")
        }
    }
}
