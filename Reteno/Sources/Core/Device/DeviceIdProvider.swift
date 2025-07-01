import Foundation

internal protocol DeviceIdProvider {
    func setDeviceId(_ deviceId: String)
    func setDeviceIdCompletionHandler(_ completion: @escaping (String) -> Void)
}
