/*
Copyright 2011-present Samuel GRAU

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

//
//  NSManagedObject+OneWaySynchronization.swift
//  SFCoreDataOneWaySynchronization
//

import Foundation
import CoreData

extension NSManagedObject {
  /**
   Sets the object priority
   
   - parameter priority: the priority of the object
   - parameter object:   the object for which to set the priority
   - parameter key:      the key used to set the priority of the object
   */
  public func sfSetObjectPriority(priority: NSNumber, object: AnyObject, key: String) {
  }
  
  /**
   Do the unique comparison between the source object and the destination object.
   Objects should be unique in a certain way. It means that a key exist that identifies them uniquely,
   event if the content of each object is different.
   
   - parameter srcObject: the source object
   - parameter dstObject: the destination object
   - parameter context:   a context, if needed for the comparison
   
   - returns: `true` if the keys that identify the objects are equal, otherwise returns `false`.
   */
  public class func sfCompareUniqueKeyFrom(
    srcObject: AnyObject,
    with dstObject: AnyObject,
    context: AnyObject?) -> Bool {
      return true
  }
  
  /**
   Insert the object referenced by data
   
   - parameter data:    the object involved in the operation
   - parameter moc:     the managed object context associated to the operation
   - parameter context: a context, if needed for the operation
   
   - returns: the newly inserted managed object
   */
  public class func sfCreateObjectWithData(
    data: AnyObject,
    managedObjectContext moc: NSManagedObjectContext,
    context: AnyObject?
    ) -> NSManagedObject? {
      fatalError("createObjectWithData(data:managedObjectContext:context:) has not been implemented")
  }
  
  /**
   Updates the object referenced by data
   
   - parameter data:    the object involved in the operation
   - parameter moc:     the managed object context associated to the operation
   - parameter context: a context, if needed for the operation
   
   - returns: the updated managed object
   */
  public class func sfUpdateObjectWithData(
    data: AnyObject,
    updatedObject: AnyObject,
    managedObjectContext moc: NSManagedObjectContext,
    context: AnyObject?
    ) -> NSManagedObject? {
      fatalError("updateObjectWithData(data:managedObjectContext:context:) has not been implemented")
  }
  
  /**
   Deletes the object referenced by data
   
   - parameter data:    the object involved in the operation
   - parameter moc:     the managed object context associated to the operation
   - parameter context: a context, if needed for the operation
   
   - returns: the deleted managed object
   */
  public class func sfDeleteObjectWithData(
    data: AnyObject,
    managedObjectContext moc: NSManagedObjectContext,
    context: AnyObject?
    ) -> NSManagedObject? {
      fatalError("deleteObjectWithData(data:managedObjectContext:context:) has not been implemented")
  }
  
  /**
   do the whole synchronization
   
   - parameter inputObjects: source (master)
   - parameter existingData: destination (slave)
   - parameter key:          the priority key
   - parameter moc:          the managed object context in which to operate the synchronization
   - parameter context:      the context if any needed
   
   - returns: the resulting set 
   */
  public class func sfSynchronizeSortedInputData(
    inputObjects: [AnyObject],
    withSortedExistingData existingData: [AnyObject],
    priorityKey key: String,
    managedObjectContext moc: NSManagedObjectContext,
    context: AnyObject? = nil) -> NSSet {
      
      var srcIndex = 0 // Source index
      var dstIndex = 0 // Destination index
      
      var resultSet = NSMutableSet()
      
      // While source index does not reach the upper bound of the existing data count
      while srcIndex < inputObjects.count {
        // We treat the current source object
        let srcMO: AnyObject = inputObjects[srcIndex]
        
        // Have we reached yet the end of the source array?
        if (dstIndex >= existingData.count) || (dstIndex < 0) {
          
          // There we are out of bounds, so this is an insertion --> Create the object
          self.owsInsertObject(object: srcMO, resultSet: &resultSet, key: key, managedObjectContext: moc, syncContext: context)
          
          // Mark as treated, and go to the next element
          srcIndex += 1
          
        } else {
          
          // Get the existing current element for comparison
          let dstMO: AnyObject = existingData[dstIndex]
          
          // If the elements are equal this means that we already have the object, and it is an update.
          if self.sfCompareUniqueKeyFrom(srcMO, with: dstMO, context: context) == true {
            
            // We should update
            self.owsUpdateObject(
              object: srcMO,
              updatedObject: dstMO,
              resultSet: &resultSet,
              key: key, managedObjectContext:
              moc, syncContext: context
            )
            
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
            if (dstIndexPlusOne >= existingData.count) || (dstIndexPlusOne < 0) {
              
              // There we are out of bounds, so this is an insertion
              self.owsInsertObject(object: srcMO, resultSet: &resultSet, key: key, managedObjectContext: moc, syncContext: context)
              srcIndex += 1
              
            } else {
              
              // We should compare to know if it is an insertion or a
              // deletion
              
              let dstMOPlusOne = existingData[dstIndexPlusOne] as! NSManagedObject
              
              if self.sfCompareUniqueKeyFrom(srcMO, with:dstMOPlusOne, context:context) == true {
                
                // If objects at this point are identical,
                // it is a deletion of the Core Data object
                self.sfDeleteObjectWithData(dstMO, managedObjectContext:moc, context:context)
                
                dstIndex += 1
                
              } else {
                self.owsInsertObject(object: srcMO, resultSet: &resultSet, key: key, managedObjectContext: moc, syncContext: context)
                srcIndex += 1
              }
            }
          }
        }
      }
      
      // The last step consist in deleting all the objects of the core data
      // that have not been deleted yet if any is remaining.
      self.owsDeleteRemainingObjects(existingData, destinationIndex: dstIndex, managedObjectContext: moc, syncContext: context)
      
      return resultSet
  }
  
  // MARK: - Private
  
  /**
  Update the result set with a given object
  
  - parameter srcMO:     the object to insert in the results
  - parameter resultSet: the result set
  - parameter key:       a user key comparison
  - parameter moc:       the context in which the operation should occur
  - parameter context:   a user context
  */
  private static func owsUpdateObject(
    object srcMO: AnyObject,
    updatedObject: AnyObject,
    inout resultSet: NSMutableSet,
    key: String,
    managedObjectContext moc: NSManagedObjectContext,
    syncContext context: AnyObject?) {
      
      if let updated = self.sfUpdateObjectWithData(srcMO, updatedObject: updatedObject, managedObjectContext:moc, context:context) {
        updated.sfSetObjectPriority(resultSet.count, object:updated, key:key)
        resultSet.addObject(updated)
      }
  }
  
  /**
   Insert in the result set a new inserted object
   
   - parameter srcMO:     the object to insert in the results
   - parameter resultSet: the result set
   - parameter key:       a user key comparison
   - parameter moc:       the context in which the operation should occur
   - parameter context:   a user context
   */
  private static func owsInsertObject(
    object srcMO: AnyObject,
    inout resultSet: NSMutableSet,
    key: String,
    managedObjectContext moc: NSManagedObjectContext,
    syncContext context: AnyObject?) {
      
      if let created: NSManagedObject = self.sfCreateObjectWithData(srcMO, managedObjectContext: moc, context: context) {
        created.sfSetObjectPriority(resultSet.count, object:created, key:key)
        /*if resultSet.containsObject(created) {
        oneWaySwellLogger.trace { return "duplicate created" }
        }*/
        resultSet.addObject(created)
      }
  }
  
  /**
   Do the last operation of the one way synchronization process
   
   - parameter existingData: Here is the array of the destination data we target to synchronize
   - parameter dstIndex:     The current index in the existingData array
   - parameter moc:          The context in which the operation should be executed
   - parameter context:      a user context, if any
   */
  private static func owsDeleteRemainingObjects(
    existingData: [AnyObject],
    destinationIndex dstIndex: Int,
    managedObjectContext moc: NSManagedObjectContext,
    syncContext context: AnyObject?) {
      
      // The last step consist in deleting all the objects of the core data
      // that have not been deleted yet if any is remaining.
      if !((dstIndex >= existingData.count) || (dstIndex < 0)) {
        for i in dstIndex..<existingData.count {
          self.sfDeleteObjectWithData(existingData[i], managedObjectContext: moc, context: context)
        }
      }
  }
}
