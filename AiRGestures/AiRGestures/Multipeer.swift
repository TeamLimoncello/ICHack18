//
//  Multipeer.swift
//  AiRGestures
//
//  Created by Lewis Bell on 27/01/2018.
//  Copyright © 2018 Lewis Bell. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MPCManagerDelegate {
    func foundPeer()
    
    func lostPeer()
    
    func connectedWithPeer(peerID: MCPeerID)
}

class Multipeer: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate {
    
    let AirGestureServiceType = "airgestures"
    var serverConnection: MCSession!
    var peer: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    
    var foundPeers = [MCPeerID]()
    var invitationHandler: ((Bool, MCSession)->Void)!
    
    var delegate: MPCManagerDelegate?

    override init() {
        super.init()
        peer = MCPeerID(displayName: UIDevice.current.name)
        serverConnection = MCSession(peer: peer)
        serverConnection.delegate = self
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: AirGestureServiceType)
        browser.delegate = self
        print("Multipeer init")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("fuck")
        print(error.localizedDescription)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?){
        print("found peer")
        foundPeers.append(peerID)
        delegate?.foundPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID){
        print("lost peer")
        for (index, aPeer) in foundPeers.enumerated(){
            if aPeer == peerID {
                foundPeers.remove(at: index)
                break
            }
        }

        delegate?.lostPeer()
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState){
        switch state{
        case MCSessionState.connected:
            print("Connected to session: \(session)")
            delegate?.connectedWithPeer(peerID: peerID)

        case MCSessionState.connecting:
            print("Connecting to session: \(session)")

        default:
            print("Did not connect to session: \(session)")
        }
    }
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do{
            try serverConnection.send(dataToSend, toPeers: [targetPeer], with: MCSessionSendDataMode.reliable)
        }catch let error{
            print(error)
            return false
        }
        return true
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?){ }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){ }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}

}
