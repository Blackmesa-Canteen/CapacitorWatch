//
//  WatchSessionDelegate.swift
//
//
//  Created by Dan Giralté on 2/24/23.
//

import WatchConnectivity
import CapacitorBackgroundRunner

public class CapWatchSessionDelegate : NSObject, WCSessionDelegate {
    var WATCH_UI = ""

    public static var shared = CapWatchSessionDelegate()

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("PHONE WatchDelagate activationDidCompleteWith")
    }

    #if os(iOS)

    public func sessionDidBecomeInactive(_ session: WCSession) {

    }

    public func sessionDidDeactivate(_ session: WCSession) {
        // dcg - do we want this?
        session.activate()
    }

    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("PHONE got didReceiveMessage: \(message)")
        if let stateData = message[STATE_DATA_KEY] as? [String: Any] {
            // Handle state data specifically
            var args: [String: Any] = [:]
            args[STATE_DATA_KEY] = stateData

            print("PHONE got STATE_DATA_KEY: \(stateData)")

            do {
                try BackgroundRunner.shared.dispatchEvent(event: "WatchConnectivity_didReceiveWatchStateData", inputArgs: args)
            } catch {
                print(error)
            }

            handleWatchStateData(stateData)
        } else {
            // Handle other messages
            var args: [String: Any] = [:]
            args["message"] = message

            print("PHONE got message: \(message)")

            do {
                try BackgroundRunner.shared.dispatchEvent(event: "WatchConnectivity_didReceiveUserInfo", inputArgs: args)
            } catch {
                print(error)
            }

            handleWatchMessage(message)
        }
    }


    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        handleWatchMessage(applicationContext)
    }

    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        // print("PHONE got didReceiveUserInfo: \(userInfo)")
        var args: [String: Any] = [:]
        args["userInfo"] = userInfo

        print("PHONE got userInfo: \(userInfo)")
        print("PHONE got args: \(args)")
        do {
            try BackgroundRunner.shared.dispatchEvent(event: "WatchConnectivity_didReceiveUserInfo", inputArgs: args)
        } catch {
            print(error)
        }

        handleWatchMessage(userInfo)
    }

    func updateViewData(_ data: [String: String]) {
        DispatchQueue.main.async {
            let _ = WCSession.default.transferUserInfo([DATA_KEY: data])
        }
    }

    func sendUI() {
        let _ = WCSession.default.transferUserInfo([UI_KEY : WATCH_UI])
    }

    func commandToJS(_ command: String) {
        NotificationCenter.default.post(name: Notification.Name(COMMAND_KEY),
                                        object: nil,
                                        userInfo: [COMMAND_KEY: command])
    }

    func watchStateDataToJS(_ stateData: [String: Any]) {
        NotificationCenter.default.post(name: Notification.Name(STATE_DATA_KEY),
                                        object: nil,
                                        userInfo: [STATE_DATA_KEY: stateData])
    }

    func handleWatchMessage(_ userInfo: [String: Any]) {
        if let command = userInfo[REQUESTUI_KEY] as? String {
            if command == REQUESTUI_VALUE {
                sendUI()
            }
        }

        if let command = userInfo[COMMAND_KEY] as? String {
            print("PHONE process command: \(command)")
            commandToJS(command)
        }
    }

    func handleWatchStateData(_ stateData: [String: Any]) {
        print("PHONE process watch state data: \(stateData)")
        watchStateDataToJS(stateData)
    }

    // Functions to pass data from iPhone to watch state data
    func updateWatchStateData(_ data: [String: Any]) {
        DispatchQueue.main.async {
            let _ = WCSession.default.transferUserInfo([STATE_DATA_KEY: data])
        }
    }

    func updateWatchStateDataByKey(_ key: String, value: Any) {
        DispatchQueue.main.async {
            let _ = WCSession.default.transferUserInfo([STATE_DATA_BY_KEY: [key: value]])
        }
    }

    func getWatchStateData(completion: @escaping ([String: Any]) -> Void) {
        print("PHONE getWatchStateData")
        if WCSession.default.isReachable {
            print("is going to transfer watch state data info: ", [WATCH_REQUEST_KEY: GET_STATE_DATA_REQUEST])
            WCSession.default.sendMessage([WATCH_REQUEST_KEY: GET_STATE_DATA_REQUEST], replyHandler: { response in
                print("completion stateData: \(response)")
                completion(response)
            }, errorHandler: { error in
                print("Error retrieving state data: \(error)")
                completion([:])
            })
        } else {
            completion([:])
        }
    }

    #endif
}
