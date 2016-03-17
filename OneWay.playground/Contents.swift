//: Playground - noun: a place where people can play

import UIKit
import CoreData
import SFCoreDataOneWaySynchronization

var str = "Hello, playground"

extension Int: OneWaySynchronizationCRUDable {
  public static func owsCreate(object: Int, userInfo: AnyObject?) -> Int? {
    return object
  }
  public static func owsUpdate(object: Int, newObject: Int, userInfo: AnyObject?) -> Int? {
    return newObject
  }
  public static func owsDelete(object: Int, userInfo: AnyObject?) -> Int? {
    return object
  }
}

extension String: OneWaySynchronizationCRUDable {
  public static func owsCreate(object: String, userInfo: AnyObject?) -> String? {
    return object
  }
  public static func owsUpdate(object: String, newObject: String, userInfo: AnyObject?) -> String? {
    return newObject
  }
  public static func owsDelete(object: String, userInfo: AnyObject?) -> String? {
    return object
  }
}

let a = [1, 2, 3, 4, 5]
let b = [2, 55]
let c = [Int]()

extension Int: OneWaySynchronizable {}
extension Double: OneWaySynchronizable {}
extension String: OneWaySynchronizable {}

Int.owsSynchronize(b, dstObjects: a, userInfo: nil)
Int.owsSynchronize(c, dstObjects: a, userInfo: nil)
Int.owsSynchronize(a, dstObjects: b, userInfo: nil)
let r = 5

let srcAS: [String] = ["a"]
let dstAS: [String] = ["a","e","d"]
Double.owsSynchronize(srcAS, dstObjects: dstAS, userInfo: nil)

extension NSManagedObject: OneWaySynchronizable {}
