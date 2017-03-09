//
//  MPCHandler.swift
//  multipeerConnectivity001
//
//  Created by David Neely on 3/3/17.
//  Copyright © 2017 David Neely. All rights reserved.
//

import UIKit

import MultipeerConnectivity

class MPCHandler: NSObject, MCSessionDelegate {
    
    var peerID: MCPeerID!
    
    var session: MCSession!
    
    var browser: MCBrowserViewController!
    
    var advertiser: MCAdvertiserAssistant? = nil
    
    func setupPeerWithDisplayName(displayName: String) {
        
        peerID = MCPeerID(displayName: displayName)
    }
    
    func setupSession() {
        
        session = MCSession(peer: peerID)
        
        session.delegate = self
    }
    
    func setupBrowser() {
     
        browser = MCBrowserViewController(serviceType: "my-game", session: session)
    }
    
    func advertiseSelf(advertise:Bool) {

        if advertise {
    
            advertiser = MCAdvertiserAssistant(serviceType: "my-game", discoveryInfo: nil, session: session)
            advertiser?.start()
            
        } else {
            
            advertiser!.stop()
            
            advertiser = nil
        }
    }

    
    
    // MARK: - MCSessionDelegate methods
    
    // Remote peer changed state.
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        let userInfo: NSDictionary = ["peerID": peerID, "state": state.rawValue]
        
        DispatchQueue.main.async {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MPC_DidChangeStateNotification"), object: nil, userInfo: userInfo as! [AnyHashable : Any])
        }

    }
    
    
    // Received data from remote peer.
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID){
        
        let userInfo: NSDictionary = ["data": data, "peerID": peerID]
        
        DispatchQueue.main.async {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MPC_DidReceiveDataNotification"), object: nil, userInfo: userInfo as! [AnyHashable : Any])
        }

    }
    
    // Received a byte stream from remote peer.
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){
        
        
    }
    
    
    
    // Start receiving a resource from remote peer.
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress){
        
        
    }
    
    
    
    // Finished receiving a resource from remote peer and saved the content
    // in a temporary location - the app is responsible for moving the file
    // to a permanent location within its sandbox.
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?){
        
        
    }



}




























