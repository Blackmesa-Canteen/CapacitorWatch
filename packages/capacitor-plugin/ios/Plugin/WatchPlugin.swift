import Foundation
import Capacitor
import WatchConnectivity

@objc(WatchPlugin)
public class WatchPlugin: CAPPlugin {

    override public func load() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleApplicationActive(notification:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleUrlOpened(notification:)),
                                               name: Notification.Name.capacitorOpenURL,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleUniversalLink(notification:)),
                                               name: Notification.Name.capacitorOpenUniversalLink,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleCommandFromWatch(_:)),
                                               name: Notification.Name(COMMAND_KEY),
                                               object: nil)

    }

    @objc func handleApplicationActive(notification: NSNotification) {
        assert(WCSession.isSupported(), "This sample requires Watch Connectivity support!")
        WCSession.default.delegate = CapWatchSessionDelegate.shared
        WCSession.default.activate()
    }

    @objc func handleUrlOpened(notification: NSNotification) {

    }

    @objc func handleUniversalLink(notification: NSNotification) {

    }

    @objc func handleCommandFromWatch(_ notification: NSNotification) {
        if let command = notification.userInfo![COMMAND_KEY] as? String {
            print("WATCH process: \(command)")
            notifyListeners("runCommand", data: ["command": command])
        }
    }

    @objc func updateWatchUI(_ call: CAPPluginCall) {
        guard let newUI = call.getString("watchUI")  else {
            return
        }

        CapWatchSessionDelegate.shared.WATCH_UI = newUI
        CapWatchSessionDelegate.shared.sendUI()

        call.resolve()
    }

    @objc func updateWatchData(_ call: CAPPluginCall) {
        guard let newData = call.getObject("data") as? [String: String] else {
            return
        }

        CapWatchSessionDelegate.shared.updateViewData(newData)
        call.resolve()
    }

    // extensions
    @objc func updateWatchStateData(_ call: CAPPluginCall) {
        let data = call.getObject("data") ?? [:]
        CapWatchSessionDelegate.shared.updateWatchStateData(data)
        call.resolve()
    }

    @objc func updateWatchStateDataByKey(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let value = call.getAny("value")
        CapWatchSessionDelegate.shared.updateWatchStateDataByKey(key, value: value)
        call.resolve()
    }

    @objc func getWatchStateData(_ call: CAPPluginCall) {
        CapWatchSessionDelegate.shared.getWatchStateData { (stateData) in
            call.resolve([STATE_DATA_KEY: stateData])
        }
    }
}
