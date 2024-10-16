//
//  CapWatchComponentView.swift
//
//
//  Created by Dan Giralté on 2/24/23.
//

import SwiftUI
import WatchConnectivity

struct CapWatchComponentView : View, Identifiable {
    var id: UUID

    var controlType: String
    var controlParams: String
    var splitParams: [String]

    var viewModel: [String: String]?

    init(_ control: String, _ vm: [String: String]? = nil) {
        viewModel = vm

        // Trim leading/trailing whitespaces and newline characters from the control string
        let trimmedControl = control.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check if the control contains parameters like "Text("..."
        if let paramRange = trimmedControl.range(of: "(") {
            controlType = String(trimmedControl[..<paramRange.lowerBound])

            // Extract the parameters inside the parentheses
            let paramString = trimmedControl[paramRange.upperBound...].dropLast() // Removes the closing parenthesis ')'

            // Remove the surrounding double quotes from the parameters
            let trimmedParamString = paramString.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            controlParams = trimmedParamString

            // Split parameters by ", " (comma followed by a space)
            splitParams = controlParams.split(separator: ", ").map { String($0.trimmingCharacters(in: CharacterSet(charactersIn: "\""))) }
        } else {
            controlType = trimmedControl
            controlParams = ""
            splitParams = []
        }

        id = UUID()
    }


    var body: some View {
        switch controlType {
        case "Text":
            CapWatchText(controlParams, viewModel)
                .foregroundColor(.white)
        case "Button":
            Button(
                action: { WCSession.default.transferUserInfo([COMMAND_KEY: splitParams[1]]) },
                label: {
                    CapWatchText(splitParams[0], viewModel)
                }
            ).foregroundColor(.white)
        case "Map":
            CapWatchMap(controlParams, viewModel)
                .frame(height: 200)
        case "Divider":
            CapWatchDivider()
        default:
            EmptyView()
        }
    }
}




