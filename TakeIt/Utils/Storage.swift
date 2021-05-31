//
//  Storage.swift
//  PeiYang Lite
//
//  Created by TwTStudio on 7/18/20.
//

import Foundation

struct Storage {
    static let defaults = UserDefaults(suiteName: "group.com.takeit.xi")!
    
    static func removeAll() {
        UserDefaults.standard.removeSuite(named: "group.com.takeit.xi")
    }
}

protocol Storable {
    init()
}

class Store<T: Codable & Storable>: ObservableObject {
    @Published var object: T
    
    private let key: String
    
    init(_ key: String) {
        self.object = T()
        self.key = key
        
        load()
    }
    
    func load() {
        
        guard let data = Storage.defaults.data(forKey: key) else {
            return
        }
        
        guard let object = try? JSONDecoder().decode(T.self, from: data) else {
            return
        }
        
        self.object = object
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(object) else {
            return
        }
        
        Storage.defaults.setValue(data, forKey: key)
    }
    
    func remove() {
        Storage.defaults.removeObject(forKey: key)
        self.object = T()
    }
}
