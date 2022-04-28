//
//  RxHubConnection.swift
//  HubSamplePhone
//
//  Created by MAC-KHUAD on 10/9/2563 BE.
//  Copyright © 2563 Pawel Kadluczka. All rights reserved.
//


import Foundation
import RxSwift
import RxCocoa
import SignalRClient

extension HubConnection: HasDelegate {
    public typealias Delegate = HubConnectionDelegate
}

public enum HubConnectionEvent{
    case didOpen(HubConnection)
    case didFailToOpen(Error)
    case didClose(Error?)
    case willReconnect(Error)
    case didReconnect
}

public class RxHubConnectionDelegateProxy:DelegateProxy<HubConnection, HubConnectionDelegate>, DelegateProxyType,HubConnectionDelegate{
   
    
    fileprivate let subject = PublishSubject<HubConnectionEvent>()
  

    
    required init(hubConnection:ParentObject) {
        super.init(parentObject: hubConnection, delegateProxy: RxHubConnectionDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register{RxHubConnectionDelegateProxy(hubConnection: $0)}
    }
    
    public static func currentDelegate(for object: HubConnection) -> HubConnectionDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: HubConnectionDelegate?, to object: HubConnection) {
        object.delegate = delegate
    }
    
    
    
    public func connectionDidOpen(hubConnection: HubConnection) {
        subject.onNext(.didOpen(hubConnection))
    }
    
    public func connectionDidFailToOpen(error: Error) {
        subject.onNext(.didFailToOpen(error))
    }
    
    public func connectionDidClose(error: Error?) {
        subject.onNext(.didClose(error))
    }
    
    public func connectionWillReconnect(error: Error) {
        subject.onNext(.willReconnect(error))
    }
    
    public func connectionDidReconnect() {
        subject.onNext(.didReconnect)
        
    }
    
    deinit {
        subject.onCompleted()
        
        
    }
}




extension Reactive where Base:HubConnection{

    public var response : Observable<HubConnectionEvent> {
        return RxHubConnectionDelegateProxy.proxy(for: base).subject
    }
    
 
    
    public func on<T1:Decodable>(method:String)->Observable<T1>{
        return Observable.create{ sub in
            self.base.on(method: method){(message:T1) in
                sub.onNext(message)
                
            }
            return Disposables.create{
                sub.onCompleted()
            }
        }
       
       
    }
    
    private func invoke<T1:Encodable>(with method:String, _ arg1: T1)->Observable<Error?>{
    
        return Observable.create{sub in
            self.base.invoke(method: method, arg1){
                sub.onNext($0)
                sub.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    public func connectInvoke<T1:Encodable>(with method:String,_ arg1: T1)->Observable<Error?>{
        return response
            .filter{event -> Bool in
                switch event {
                case .didOpen(_):
                    return true
                    
                default :
                    return false
                }
                
         }.flatMap{event -> Observable<Error?> in
            switch event{
            case .didOpen(_):
                return self.invoke(with: method, arg1)
                
            default :
                return Observable.just(nil)
            }
        }
    }
    
    
    public var connected:Observable<()>{
        response.filter{
            switch $0 {
            case .didOpen(_), .didReconnect:
                return true
                
            default :
                return false
            }
        }
        .map{_ in ()}
    }
    
    
    public var isConnected:Observable<Error?>{
        return response.map{
            switch $0 {
            case .didOpen(_):
                return nil
            case .didFailToOpen(let e):
                return e
                
            default :
                return nil
            }
        }
      
    }
    
     
    
    
}

extension HubConnection:ReactiveCompatible {}
