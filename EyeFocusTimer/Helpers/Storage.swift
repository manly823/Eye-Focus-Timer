import Foundation

final class Storage {
    static let shared = Storage()
    private let enc = JSONEncoder()
    private let dec = JSONDecoder()
    private init() {}
    func save<T: Codable>(_ v: T, forKey k: String) { if let d = try? enc.encode(v) { UserDefaults.standard.set(d, forKey: k) } }
    func load<T: Codable>(forKey k: String, default dv: T) -> T { guard let d = UserDefaults.standard.data(forKey: k), let v = try? dec.decode(T.self, from: d) else { return dv }; return v }
}
