//
//  ViewController.swift
//  multipeerConnectivity001
//
//  Created by David Neely on 3/3/17.
//  Copyright © 2017 David Neely. All rights reserved.
//

import UIKit

import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate {
    
    
    
    @IBOutlet var fields: [TTTImageView]!
    
    var appDelegate: AppDelegate!
    
    var currentPlayer = "x"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.mpcHandler.setupPeerWithDisplayName(displayName: UIDevice.current.name)
        
        appDelegate.mpcHandler.setupSession()
        
        appDelegate.mpcHandler.advertiseSelf(advertise: true)
        
        NotificationCenter.default.addObserver(self, selector: "peerChangedStateWithNotification", name: NSNotification.Name(rawValue: "MPC_DidChangeStateNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: "handleReceivedDataWithNotification", name: NSNotification.Name(rawValue: "MPC_DidReceiveDataNotification"), object: nil)
        
        setupGameLogic()
    }
    
    @IBAction func connectToPlayer(_ sender: Any) {
        
        if appDelegate.mpcHandler.session != nil {
            
            appDelegate.mpcHandler.setupBrowser()
            
            appDelegate.mpcHandler.browser.delegate = self
            
            self.present(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        }
    }
    
    // State checking connections
    
    func peerChangedStateWithNotification(notification: NSNotification ) {
        
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        
        let state = userInfo.object(forKey: "state") as! Int
        
        if state != MCSessionState.connecting.rawValue {
            
            self.navigationItem.title = "Connected" // Updates the title at the top of the game to show that you're connected
            
        }
    }
    
    func handleReceivedDataWithNotification(notification: NSNotification) {
        
        // deal with the data that has been sent to the user
        
        let userInfo = notification.userInfo! as Dictionary
        
        let receivedData: NSData = userInfo["data"] as! NSData
        
        do {
            
            let message = try JSONSerialization.jsonObject(with: receivedData as Data, options: JSONSerialization.ReadingOptions.allowFragments)
            
            let senderPeerId: MCPeerID = userInfo["peerID"] as! MCPeerID
            
            let senderDisplayName = senderPeerId.displayName
            
            print(message)
            
        } catch {
            
            print(error.localizedDescription)
        }
    }
    
    
    
    func fieldTapped (recognizer: UITapGestureRecognizer) {
        
        let tappedField = recognizer.view as! TTTImageView
        
        tappedField.setPlayer(_player: currentPlayer)
        
        // Inform other player that we did a move.
        // Send them a dictionary to send to the other device.
        // Two key value pairs: field
        //tappedField.tag // gives us idea of the index of every field in the outlet collection.
    
        let messageDict: NSDictionary = ["field": tappedField.tag, "player": currentPlayer]
        
        do {
            
            let messageData = try JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)

        } catch {
            
            print(error.localizedDescription)
        }
        
        //TODO: Check the results
    }

    func setupGameLogic() {
        
        for index in 0...fields.count - 1 {
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(fieldTapped)) //TODO: Add selector to make this work.
            
            gestureRecognizer.numberOfTapsRequired = 1
            
            fields[index].addGestureRecognizer(gestureRecognizer)
        }
    }
    
    // MARK: - Multipeer delegate methods
    
    
    // Notifies the delegate, when the user taps the done button.
    public func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    
    // Notifies delegate that the user taps the cancel button.
    public func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
}


















































