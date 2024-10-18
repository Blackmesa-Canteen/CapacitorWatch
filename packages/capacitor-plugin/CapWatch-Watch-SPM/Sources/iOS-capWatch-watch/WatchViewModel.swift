//
//  WatchViewModel.swift
//
//
//  Created by Dan Giralté on 2/24/23.
//

import Foundation
import WatchConnectivity
import SwiftUI

public class WatchViewModel: NSObject, WCSessionDelegate, ObservableObject {
    public func sessionDidBecomeInactive(_ session: WCSession) {
    }

    public func sessionDidDeactivate(_ session: WCSession) {
        self.session.activate()
    }

    var session: WCSession

    public static var shared = WatchViewModel()

    @AppStorage(SAVEDUI_KEY) var savedUI: String = ""

    @Published var watchUI = "Text(\"Capacitor WATCH\")\nButton(\"Add One\", \"inc\")"
    @Published var viewData: [String: String]?

    // state data handling
    @Published var stateData: [String: Any] = [:]

    init(session: WCSession = .default, viewData: [String: String]? = nil) {
        self.session = session
        self.viewData = viewData

        super.init()

        if savedUI != "" {
            self.watchUI = self.savedUI
        }
    }

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // apple docs say this won't work on simulator
        if let error = error {
            print("Activation error: \(error.localizedDescription)")
            return
        }

        if WatchViewModel.shared.watchUI.isEmpty {
            let _ = session.transferUserInfo(REQUESTUI)
        }
    }

    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handlePhoneMessage(message)
    }

    public func session(_ session: WCSession,
                        didReceiveMessage message: [String: Any],
                        replyHandler: @escaping ([String: Any]) -> Void) {
        print("Watch get didReceiveMessage with replyHandler, message: \(message)")
        // Check if the message contains the correct request key
        if let request = message[WATCH_REQUEST_KEY] as? String, request == GET_STATE_DATA_REQUEST {
            // Prepare the state data to send back
            let stateData: [String: Any] = self.stateData

            // Send the state data back using the reply handler
            print("replying with state data: \(stateData)")
            replyHandler(stateData)
        } else {
            // If the request key doesn't match, send an empty response or handle accordingly
            replyHandler([:])
        }
    }

    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handlePhoneMessage(applicationContext)
    }

    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handlePhoneMessage(userInfo)
    }

    // required protocol stubs?
    //func sessionDidBecomeInactive(_ session: WCSession) {}

    //func sessionDidDeactivate(_ session: WCSession) {}

    func handlePhoneMessage(_ userInfo: [String: Any]) {
        DispatchQueue.main.async {
            if let newUI = userInfo[UI_KEY] as? String {
                self.watchUI = newUI
                print("new watchUI: \(self.watchUI)")
                self.savedUI = self.watchUI
            }

            if let newViewData = userInfo[DATA_KEY] as? [String: String] {
                self.viewData = newViewData
            }

            if let receivedStateData = userInfo[STATE_DATA_KEY] as? [String: Any] {
                self.stateData = receivedStateData
            }

            if let receivedStateDataByKey = userInfo[STATE_DATA_BY_KEY] as? [String: Any] {
                for (key, value) in receivedStateDataByKey {
                    self.stateData[key] = value
                }
            }
        }
    }

    // state data handling
    public func updateStateData(_ data: [String: Any]) {
        DispatchQueue.main.async {
            self.stateData = data
            self.sendStateDataToiPhone()
        }
    }

    public func updateStateDataByKey(_ key: String, value: Any) {
        DispatchQueue.main.async {
            self.stateData[key] = value
            self.sendStateDataToiPhone()
        }
    }

    public func getStateDataByKey(_ key: String) -> Any? {
        return stateData[key]
    }

    public func getStateData() -> [String: Any] {
        return stateData
    }

    private func sendStateDataToiPhone() {
        guard session.isReachable else {
            return
        }

        session.sendMessage([STATE_DATA_KEY: stateData], replyHandler: nil) { error in
            print("Error sending state data to iPhone: \(error.localizedDescription)")
        }
    }
}
