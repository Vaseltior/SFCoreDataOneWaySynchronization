//
//  ArrayExtension.swift
//  SFCoreDataOneWaySynchronization
//
//  Created by Samuel Grau on 08/03/2016.
//  Copyright © 2016 Samuel GRAU. All rights reserved.
//

import Foundation

extension Array {
  ///
  /// Tell if the given index is out of the bounds of the current array.
  ///
  /// - parameter index: The index to test boundaries
  ///
  /// - returns: true if the index is out of bounds, otherwise, false
  ///
  public func sfIsIndexOutOfBounds(index: Int) -> Bool {
    return ((index >= self.count) || (index < 0))
  }
}
