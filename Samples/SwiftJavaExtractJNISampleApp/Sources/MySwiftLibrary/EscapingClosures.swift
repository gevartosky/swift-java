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

public struct CustomResult {
  public let value: Int64
  public let error: String?

  public init(value: Int64, error: String?) {
    self.value = value
    self.error = error
  }
}

public struct CustomerSupportClient: @unchecked Sendable {
    public var _getUserLoginStatus: () -> Bool
    public var _getCustomerSupportProfile: (String) async -> String

    public func getUserLoginStatus() -> Bool {
        return _getUserLoginStatus()
    }

    public func getCustomerSupportProfile(_ profile: String) async -> String {
        return await _getCustomerSupportProfile(profile)
    }
    
    public static func make(
        getUserLoginStatus: @escaping () -> Bool,
        getCustomerSupportProfile: @escaping (String) async -> String
    ) -> CustomerSupportClient {
        CustomerSupportClient(
            getUserLoginStatus: getUserLoginStatus,
            getCustomerSupportProfile: getCustomerSupportProfile
        )
    }
    
    private init(
        getUserLoginStatus: @escaping () -> Bool,
        getCustomerSupportProfile: @escaping (String) async -> String
    ) {
        self._getUserLoginStatus = getUserLoginStatus
        self._getCustomerSupportProfile = getCustomerSupportProfile
    }

    public static var mockSuccess: CustomerSupportClient {
        CustomerSupportClient(
            getUserLoginStatus: { true },
            getCustomerSupportProfile: { _ in "" }
        )
    }
}

public class CallbackManager {
  private var callback: (() -> Void)?
  public var intCallback: ((Int64) async -> CustomResult)?
  
  public init() {}

  public static func make(a: @escaping () -> Void, b: @escaping (Int64) async -> CustomResult) -> CallbackManager {
    CallbackManager(callback: a, intCallback: b)
  }
  
  public func setCallback(callback: @escaping () -> Void) {
    self.callback = callback
  }
  
  public func triggerCallback() {
    callback?()
  }
  
  public func clearCallback() {
    callback = nil
  }
  
  public func setIntCallback(callback: @escaping (Int64) async -> CustomResult) {
    self.intCallback = callback
  }
  
  public func triggerIntCallback(value: Int64) async -> CustomResult? {
    return await intCallback?(value)
  }

  private init(callback: @escaping () -> Void, intCallback: @escaping (Int64) async -> CustomResult) {
    self.callback = callback
    self.intCallback = intCallback
  }
}

public func delayedExecution(closure: @escaping (Int64) -> Int64, input: Int64) -> Int64 {
  // In a real implementation, this might be async
  // For testing purposes, we just call it synchronously
  return closure(input)
}

public class ClosureStore {
  private var closures: [() -> Void] = []
  
  public init() {}
  
  public func addClosure(closure: @escaping () -> Void) {
    closures.append(closure)
  }
  
  public func executeAll() {
    for closure in closures {
      closure()
    }
  }
  
  public func clear() {
    closures.removeAll()
  }
  
  public func count() -> Int64 {
    return Int64(closures.count)
  }
}

public func multipleEscapingClosures(
  onSuccess: @escaping (Int64) -> Void,
  onFailure: @escaping (Int64) -> Void,
  condition: Bool
) {
  if condition {
    onSuccess(42)
  } else {
    onFailure(-1)
  }
}

