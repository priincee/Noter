//
//  DebounceMod.swift
//  Noter
//
//  Created by Prince Embola on 09/02/2022.
//

import Foundation
import Combine
import SwiftUI


extension View {
    func onDebouncedChange<V>(
        of binding: Binding<V>,
        debounceFor dueTime: TimeInterval,
        perform action: @escaping (V) -> Void
    ) -> some View where V: Equatable {
        modifier(ListenDebounce(binding: binding, dueTime: dueTime, action: action))
    }
}

private struct ListenDebounce<Value: Equatable>: ViewModifier {
    @Binding
    var binding: Value
    @StateObject
    var debounceSubject: ObservableDebounceSubject<Value, Never>
    let action: (Value) -> Void

    init(binding: Binding<Value>, dueTime: TimeInterval, action: @escaping (Value) -> Void) {
        _binding = binding
        _debounceSubject = .init(wrappedValue: .init(dueTime: dueTime))
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: binding) { value in
                debounceSubject.send(value)
            }
            .onReceive(debounceSubject) { value in
                action(value)
            }
    }
}

private final class ObservableDebounceSubject<Output: Equatable, Failure>: Subject, ObservableObject where Failure: Error {
    private let passthroughSubject = PassthroughSubject<Output, Failure>()

    let dueTime: TimeInterval

    init(dueTime: TimeInterval) {
        self.dueTime = dueTime
    }

    func send(_ value: Output) {
        passthroughSubject.send(value)
    }

    func send(completion: Subscribers.Completion<Failure>) {
        passthroughSubject.send(completion: completion)
    }

    func send(subscription: Subscription) {
        passthroughSubject.send(subscription: subscription)
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        passthroughSubject
            .removeDuplicates()
            .debounce(for: .init(dueTime), scheduler: RunLoop.main)
            .receive(subscriber: subscriber)
    }
}
