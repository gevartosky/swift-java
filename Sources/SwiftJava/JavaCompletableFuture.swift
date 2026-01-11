//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift.org project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift.org project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import JavaTypes

/// Swift wrapper for java.util.concurrent.CompletableFuture<T>
/// Used primarily for async escaping closure support where Java returns CompletableFuture.
@JavaClass("java.util.concurrent.CompletableFuture")
public struct JavaCompletableFuture<T: AnyJavaObject>: @unchecked Sendable {
  /// Waits if necessary for this future to complete, and then returns its result.
  @JavaMethod
  public func get() -> JavaObject?
  
  /// Returns true if this CompletableFuture completed exceptionally.
  @JavaMethod
  public func isCompletedExceptionally() -> Bool
  
  /// Returns true if completed in any fashion: normally, exceptionally, or via cancellation.
  @JavaMethod
  public func isDone() -> Bool
}

