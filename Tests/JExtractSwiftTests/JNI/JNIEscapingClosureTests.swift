//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift.org project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift.org project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import JExtractSwiftLib
import Testing

@Suite
struct JNIEscapingClosureTests {
  let source =
    """
    public class CallbackManager {
      private var callback: (() -> Void)?
      
      public init() {}
      
      public func setCallback(callback: @escaping () -> Void) {
        self.callback = callback
      }
      
      public func triggerCallback() {
        callback?()
      }
      
      public func clearCallback() {
        callback = nil
      }
    }
    
    public func delayedExecution(closure: @escaping (Int64) -> Int64, input: Int64) -> Int64 {
      // Simplified for testing - would normally be async
      return closure(input)
    }
    """

  @Test
  func escapingEmptyClosure_javaBindings() throws {
    let simpleSource =
      """
      public func setCallback(callback: @escaping () -> Void) {}
      """
    
    try assertOutput(input: simpleSource, .jni, .java, expectedChunks: [
      """
      public static class setCallback {
        @FunctionalInterface
        public interface callback {
          void apply();
        }
      }
      """,
      """
      /**
       * Downcall to Swift:
       * {@snippet lang=swift :
       * public func setCallback(callback: @escaping () -> Void)
       * }
       */
      public static void setCallback(com.example.swift.SwiftModule.setCallback.callback callback) {
        SwiftModule.$setCallback(callback);
      }
      """
    ])
  }

  @Test
  func escapingClosureWithParameters_javaBindings() throws {
    let source =
      """
      public func delayedExecution(closure: @escaping (Int64) -> Int64) {}
      """
    
    try assertOutput(input: source, .jni, .java, expectedChunks: [
      """
      public static class delayedExecution {
        @FunctionalInterface
        public interface closure {
          long apply(long _0);
        }
      }
      """
    ])
  }

  @Test
  func escapingClosure_swiftThunks() throws {
    let source =
      """
      public func setCallback(callback: @escaping () -> Void) {}
      """
    
    try assertOutput(
      input: source,
      .jni,
      .swift,
      detectChunkByInitialLines: 1,
      expectedChunks: [
        // Synthetic protocol
        """
        protocol _SwiftClosure_SwiftModule_setCallback_callback {
          func apply()
        }
        """,
        // Wrapper struct
        """
        struct _SwiftClosureWrapper_SwiftModule_setCallback_callback: _SwiftClosure_SwiftModule_setCallback_callback {
        """,
        // JavaObjectHolder for escaping closure lifetime management
        """
        let closureContext_callback$ = JavaObjectHolder(object: callback, environment: environment)
        """,
        // Wrapper instantiation
        """
        let protocolWrapper$ = _SwiftClosureWrapper_SwiftModule_setCallback_callback(javaInterface: javaInterface$)
        """
      ]
    )
  }

  @Test
  func asyncEscapingClosure_swiftThunks() throws {
    let source =
      """
      public func setAsyncCallback(callback: @escaping (Int64) async -> Int64) {}
      """
    
    try assertOutput(
      input: source,
      .jni,
      .swift,
      detectChunkByInitialLines: 1,
      expectedChunks: [
        // Synthetic protocol with async
        """
        protocol _SwiftClosure_SwiftModule_setAsyncCallback_callback {
          func apply(_ _0: Int64) async -> Int64
        }
        """,
        // Wrapper struct
        """
        struct _SwiftClosureWrapper_SwiftModule_setAsyncCallback_callback: _SwiftClosure_SwiftModule_setAsyncCallback_callback {
        """
      ]
    )
  }

  @Test
  func nonEscapingClosure_stillWorks() throws {
    let source =
      """
      public func call(closure: () -> Void) {}
      """
    
    try assertOutput(input: source, .jni, .java, expectedChunks: [
      """
      @FunctionalInterface
      public interface closure {
        void apply();
      }
      """
    ])
  }

  @Test
  func asyncEscapingClosure_javaBindings_returnsCompletableFuture() throws {
    let source =
      """
      public func setAsyncCallback(callback: @escaping (Int64) async -> Int64) {}
      """
    
    try assertOutput(input: source, .jni, .java, expectedChunks: [
      """
      @FunctionalInterface
      public interface callback {
        java.util.concurrent.CompletableFuture<java.lang.Long> apply(long _0);
      }
      """
    ])
  }

  @Test
  func asyncVoidEscapingClosure_javaBindings_returnsCompletableFutureVoid() throws {
    let source =
      """
      public func setAsyncVoidCallback(callback: @escaping () async -> Void) {}
      """
    
    try assertOutput(input: source, .jni, .java, expectedChunks: [
      """
      @FunctionalInterface
      public interface callback {
        java.util.concurrent.CompletableFuture<java.lang.Void> apply();
      }
      """
    ])
  }
}

