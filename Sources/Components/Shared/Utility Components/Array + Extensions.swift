//
//  Array + Extensions.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 02/12/21.
//

import Foundation


extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

extension Array where Element : Collection, Element.Index == Int {
    func indexPath(where predicate: (Element.Iterator.Element) -> Bool) -> IndexPath? {
        for (i, row) in self.enumerated() {
            if let j = row.index(where: predicate) {
                return IndexPath(indexes: [i, j])
            }
        }
        return nil
    }
}

extension Array {
     func contains<T>(obj: T) -> Bool where T: Equatable {
         return !self.filter({$0 as? T == obj}).isEmpty
     }
 }

extension Array where Element: Equatable {
    func subtracting(_ array: Array<Element>) -> Array<Element> {
        self.filter { !array.contains($0) }
    }
}

