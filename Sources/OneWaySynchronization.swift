//
//  OneWaySynchronization.swift
//  SFCoreDataOneWaySynchronization
//
//  Created by Samuel Grau on 16/03/2016.
//  Copyright © 2016 Samuel GRAU. All rights reserved.
//

import Foundation
import CoreData

public protocol Ordered {
  func precedes(other: Self) -> Bool
}
public extension Ordered where Self: Comparable {
  func precedes(other: Self) -> Bool { return self < other }
}
extension Int: Ordered {}
extension String: Ordered {}
extension Double: Ordered {}

public protocol OneWaySynchronizable {
  static func owsSynchronize<T where T: Ordered, T: OneWaySynchronizationCRUDable, T: OneWaySynchronizable, T: Comparable>(
    srcObjects: [T],
    dstObjects: [T],
    userInfo: AnyObject?) -> [T]
  func owsIsEqualTo(other: OneWaySynchronizable) -> Bool
}

public extension OneWaySynchronizable where Self: Comparable {
  func owsIsEqualTo(other: OneWaySynchronizable) -> Bool {
    if let o = other as? Self { return self == o }
    return false
  }
}

public protocol OneWaySynchronizationCreatable {
  static func owsCreate(object: Self, userInfo: AnyObject?) -> Self?
}
public protocol OneWaySynchronizationUpdatable {
  static func owsUpdate(object: Self, newObject: Self, userInfo: AnyObject?) -> Self?
}
public protocol OneWaySynchronizationDeletable {
  static func owsDelete(object: Self, userInfo: AnyObject?) -> Self?
}

public protocol OneWaySynchronizationCRUDable: OneWaySynchronizationCreatable, OneWaySynchronizationUpdatable, OneWaySynchronizationDeletable {
  
}

public extension OneWaySynchronizable {
  public static func owsSynchronize<T where T: Ordered, T: OneWaySynchronizationCRUDable, T: OneWaySynchronizable, T: Comparable>(
    srcObjects: [T],
    dstObjects: [T],
    userInfo: AnyObject?) -> [T] {
      
      var srcIndex = 0 // Source index
      var dstIndex = 0 // Destination index
      
      var resultSet = [T]()
      
      // While source index does not reach the upper bound of the existing data count
      while srcIndex < srcObjects.count {
        // We treat the current source object
        let srcMO = srcObjects[srcIndex]
        
        // Have we reached yet the end of the source array?
        if (dstIndex >= dstObjects.count) || (dstIndex < 0) {
          
          // There we are out of bounds, so this is an insertion --> Create the object
          if let c = T.owsCreate(srcMO, userInfo: userInfo) {
            resultSet.append(c)
          }
          
          // Mark as treated, and go to the next element
          srcIndex += 1
          
        } else {
          
          // Get the existing current element for comparison
          let dstMO = dstObjects[dstIndex]
          
          // If the elements are equal this means that we already have the object, and it is an update.
          if srcMO.owsIsEqualTo(dstMO) {
            
            // We should update
            if let u = T.owsUpdate(dstMO, newObject: srcMO, userInfo: userInfo) {
              resultSet.append(u)
            }
            
            // We progress on both indexes
            dstIndex += 1
            srcIndex += 1
            
          } else {
            //
            // If there is a difference this means that it could be an
            // insertion or a deletion
            // But we should find out which one it is.
            // - We should delete from Core Data if the next element is equal.
            // - We should insert an element into the Core Data if both the
            // current and the following element are different
            // - We should delete any object
            //
            
            // So we try to get the next Core Data identifier
            let dstIndexPlusOne = dstIndex + 1
            
            // Do this element exist ?
            if (dstIndexPlusOne >= dstObjects.count) || (dstIndexPlusOne < 0) {
              
              // There we are out of bounds, so this is an insertion
              if let c = T.owsCreate(srcMO, userInfo: userInfo) {
                resultSet.append(c)
              }
              srcIndex += 1
              
            } else {
              
              // We should compare to know if it is an insertion or a
              // deletion
              
              let dstMOPlusOne = dstObjects[dstIndexPlusOne]
              
              if srcMO.owsIsEqualTo(dstMOPlusOne) {
                // If objects at this point are identical,
                // it is a deletion of the Core Data object
                T.owsDelete(dstMO, userInfo: userInfo)
                dstIndex += 1
                
              } else {
                if let c = T.owsCreate(srcMO, userInfo: userInfo) {
                  resultSet.append(c)
                }
                srcIndex += 1
              }
            }
          }
        }
      }
      
      // The last step consist in deleting all the objects of the core data
      // that have not been deleted yet if any is remaining.
      if !((dstIndex >= dstObjects.count) || (dstIndex < 0)) {
        for i in dstIndex..<dstObjects.count {
          T.owsDelete(dstObjects[i], userInfo: userInfo)
        }
      }
      
      return resultSet
  }
}
