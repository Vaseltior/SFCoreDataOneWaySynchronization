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
//  ArrayExtension.swift
//  SFCoreDataOneWaySynchronization
//

import Foundation

extension Array {
  /**
   Tell if the given index is out of the bounds of the current array.

   - parameter index: The index to test boundaries

   - returns: `true` if the index is out of bounds, otherwise, `false`.
   */
  public func sfIsIndexOutOfBounds(index: Int) -> Bool {
    return ((index >= self.count) || (index < 0))
  }
}
