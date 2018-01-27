//
//  GestureServiceManager.swift
//  AirGestures
//
//  Created by Charlie Harding on 27/01/2018.
//  Copyright © 2018 Team Limoncello. All rights reserved.
//

import MultipeerConnectivity

class GestureServiceManager : NSObject, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    
    var localPeerID : MCPeerID?
    let AirGestureServiceType = "airgestures-link"
    
    override init() {
        super.init()
        
        localPeerID = MCPeerID(displayName: Host.current().localizedName ?? "\(NSUserName())'s Mac")
        
        let serviceAdvertiser = MCNearbyServiceAdvertiser(peer: localPeerID!,
                                                          discoveryInfo: nil,
                                                          serviceType: AirGestureServiceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession) -> Void) {
        let session = MCSession(peer: localPeerID!,
                                securityIdentity: nil,
                                encryptionPreference: .none)
        
        session.delegate = self
        
        invitationHandler(true, session)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) -> () {
        if state == MCSessionState.connected {
            let message = "Hello \(peerID.displayName), welcome to the chat!"
            let messageData = message.data(using: String.Encoding.utf8)!
            
            try! session.send(messageData, toPeers: [peerID], with: .reliable)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print(String(data: data, encoding: String.Encoding.utf8) ?? "<bad data>")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
//        <#code#>
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
//        <#code#>
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
//        <#code#>
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        <#code#>
    }
}