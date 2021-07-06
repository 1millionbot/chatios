//
//  Extensions.swift
//  OneMillionBot
//
//  Created by Adrián R on 20/5/21.
//

import Foundation
import Combine

extension Publisher {
    func doOnNext(_ handleOutput: @escaping (Output) -> Void) -> AnyPublisher<Output, Failure> {
        return handleEvents(receiveOutput: { output in
            handleOutput(output)
        }).eraseToAnyPublisher()
    }
    
    func doOnError(_ handleOutput: @escaping (Error) -> Void) -> AnyPublisher<Output, Failure> {
        return handleEvents(receiveCompletion: { event in
            if case let .failure(error) = event {
                handleOutput(error)
            }
        }).eraseToAnyPublisher()
    }
    
    func pipe<F: Subject, V>(
        error subject: F,
        value: @escaping (V) -> Void = { _ in }
    ) -> AnyCancellable
    where F.Output == Error,
          F.Failure == Never,
          V == Output
    {
        sink(
            receiveCompletion: { event in
                if case let .failure(error) = event {
                    subject.send(error)
                }
            },
            receiveValue: { value($0) }
        )
    }
    
    func pipe<S: Subject, F: Subject>(
        to subject: S,
        e errorSubject: F
    ) -> AnyCancellable
    where S.Failure == Never,
          S.Output == Self.Output,
          F.Failure == Never,
          F.Output == Error
    {
        return sink(
            receiveCompletion: { event in
                if case let .failure(error) = event {
                    errorSubject.send(error)
                }
            },
            receiveValue: subject.send
        )
    }
}
