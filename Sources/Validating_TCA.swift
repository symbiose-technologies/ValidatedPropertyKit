//
//  File.swift
//  
//
//  Created by Ryan Mckinney on 3/28/23.
//

import Foundation

/// A Validating PropertyWrapper
@propertyWrapper
public struct Validating<Value>: Validatable {
    
    private var value: Value
    public let validation: Validation<Value>
    private var hasChanges = false
    public private(set) var isValid: Bool
    
    public var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            if !hasChanges {
                hasChanges = true
            }
            isValid = validation.validate(newValue)
        }
    }
    
    public var projectedValue: Self {
        get { self }
        set { self = newValue }
    }
    
    public init(wrappedValue: Value, _ validation: Validation<Value>) {
        self.value = wrappedValue
        self.validation = validation
        self.isValid = validation.validate(wrappedValue)
    }
    
    public init<WrappedValue>(wrappedValue: WrappedValue?,
                              _ validation: Validation<WrappedValue>,
                              isNilValid: @autoclosure @escaping () -> Bool = false)
    where WrappedValue? == Value {
        self.init(wrappedValue: wrappedValue ?? Value.none,
                  .init(validation,
                        isNilValid: isNilValid()))
    }
    
    public var isInvalid: Bool {
        !isValid
    }
    
    public var isInvalidAfterChanges: Bool {
        hasChanges && isInvalid
    }
    
    public var validatedValue: Value? {
        isValid ? value : nil
    }
}

extension Validating: Equatable where Value: Equatable {
    public static func == (lhs: Validating<Value>, rhs: Validating<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension Validating: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
