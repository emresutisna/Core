//
//  File.swift
//  
//
//  Created by Nanang Sutisna on 15/12/20.
//

import Combine

public protocol UseCase {
    associatedtype Request
    associatedtype Response
    
    func execute(request: Request?) -> AnyPublisher<Response, Error>
}
