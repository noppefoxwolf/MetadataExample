//
//  ViewController.swift
//  MetadataExample
//
//  Created by Tomoya Hirano on 2018/06/20.
//  Copyright © 2018年 Tomoya Hirano. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    encodable()
    mirror()
    memory()
  }
  
  func encodable() {
    let data = try! JSONEncoder().encode(Example())
    let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
    print((json as! [String : Any]).keys)
  }
  
  func mirror() {
    let props = Mirror(reflecting: Example()).children.map({ $0.label })
    print(props)
  }
  
  func memory() {
    let type: Any.Type = Example.self
    let typeAsPointer = unsafeBitCast(type, to: UnsafeMutablePointer<Int64>.self)
    let layout = UnsafeRawPointer(typeAsPointer.advanced(by: 0)).assumingMemoryBound(to: Layout.self)
    let cString = layout.pointee.nominalTypeDescriptor.pointee.fieldNames.advanced()
    let props = String(cString: cString)
    print(props)
  }
}

struct Layout {
  var kind: Int
  var nominalTypeDescriptor: UnsafeMutablePointer<NominalTypeDescriptor>
}

struct NominalTypeDescriptor {
  var mangledName: Int32
  var numberOfFields: Int32
  var offsetToTheFieldOffsetVector: Int32
  var fieldNames: RelativePointer<Int32, CChar>
  var fieldTypeAccessor: Int32
  var metadataPattern: Int32
  var somethingNotInTheDocs: Int32
  var genericParameterVector: Int32
  var inclusiveGenericParametersCount: Int32
  var exclusiveGenericParametersCount: Int32
}

struct RelativePointer<Offset: IntegerConvertible, Pointee> {
  var offset: Offset
  
  mutating func pointee() -> Pointee {
    return advanced().pointee
  }
  
  mutating func advanced() -> UnsafeMutablePointer<Pointee> {
    let offsetCopy = self.offset
    return withUnsafePointer(to: &self) { p in
      return p.raw.advanced(by: offsetCopy.getInt()).assumingMemoryBound(to: Pointee.self).mutable
    }
  }
}

protocol IntegerConvertible {
  func getInt() -> Int
}

extension UnsafePointer {
  var raw: UnsafeRawPointer {
    return UnsafeRawPointer(self)
  }
  var mutable: UnsafeMutablePointer<Pointee> {
    return UnsafeMutablePointer<Pointee>(mutating: self)
  }
}

extension Int32: IntegerConvertible {
  func getInt() -> Int {
    return Int(self)
  }
}

struct Example: Encodable {
  var title: String = "example"
}




