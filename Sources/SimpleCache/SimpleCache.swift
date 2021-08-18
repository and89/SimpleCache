import Foundation

final class SimpleCache<T: AnyObject> {
    private let cache = NSCache<NSString, T>()
    private let queue = DispatchQueue(label: "com.simple.Cache", attributes: .concurrent)

    func object(_ forKey: String, completion: @escaping (T?) -> Void) {
        queue.async { [weak self] in
            let cachedObject = self?.cache.object(forKey: forKey as NSString)
            completion(cachedObject)
        }
    }
    
    func set(_ object: T, _ forKey: String) {
        let writeItem = DispatchWorkItem(qos: .default, flags: .barrier) { [weak self] in
            self?.cache.setObject(object, forKey: forKey as NSString)
        }
        queue.async(execute: writeItem)
    }
    
    func clear() {
        let clearItem = DispatchWorkItem(qos: .default, flags: .barrier) { [weak self] in
            self?.cache.removeAllObjects()
        }
        queue.async(execute: clearItem)
    }
}
