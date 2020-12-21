//
//  File.swift
//  
//
//  Created by Nanang Sutisna on 17/12/20.
//

import SwiftUI
import Combine

public class SearchPresenter<Response, Interactor: UseCase>: ObservableObject where Interactor.Request == String, Interactor.Response == [Response] {
    
    private var cancellables: Set<AnyCancellable> = []
    private var subscriptionToken: AnyCancellable?
    
    private let _useCase: Interactor
    
    @Published public var list: [Response] = []
    @Published public var errorMessage: String = ""
    @Published public var isLoading: Bool = false
    @Published public var isError: Bool = false
    @Published public var isSearchRun: Bool = false
    @Published public var keyword = ""
    
    public init(useCase: Interactor) {
        _useCase = useCase
    }
    
    public func startObserve() {
        guard subscriptionToken == nil else { return }
        self.subscriptionToken = self.$keyword
            .map { [weak self] text in
                self?.list = []
                self?.isError = false
                return text
                
            }.throttle(for: 1, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in self?.search(query: $0) }
    }
    
    public func search(query: String) {
        self.list = []
        self.isLoading = false
        self.isError = false
        
        guard !query.isEmpty else {
            return
        }
        
        self.isLoading = true
        isSearchRun = true
        _useCase.execute(request: query)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isError = true
                    self.isLoading = false
                case .finished:
                    self.isLoading = false
                }
            }, receiveValue: { list in
                self.list = list
            })
            .store(in: &cancellables)
    }
    
    public func clear() {
        self.list.removeAll()
        self.isSearchRun = false
    }
    
    deinit {
        self.subscriptionToken?.cancel()
        self.subscriptionToken = nil
    }
}
