//
//  DAppCheckPermissionsMessageHandler.swift
//  Cyton
//
//  Created by 晨风 on 2018/12/3.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation

class DAppPermissionsMessageHandler: DAppNativeMessageHandler {
    enum MessageName: String {
        case checkPermissions
        case requestPermissions
    }

    struct Parameters: Decodable {
        let permission: Permission
    }

    enum Permission: String, Decodable {
        case camera = "permission"
    }

    override var messageNames: [String] {
        return [
            MessageName.checkPermissions.rawValue,
            MessageName.requestPermissions.rawValue
        ]
    }

    override func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        super.userContentController(userContentController, didReceive: message)
        guard let data = try? JSONSerialization.data(withJSONObject: message.body, options: .prettyPrinted) else { return }
        if message.name == MessageName.checkPermissions.rawValue {
            let permission = (try? JSONDecoder().decode(Parameters.self, from: data))?.permission ?? .camera
            if permission == .camera {
                if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                    callback(result: .success(["result": true]))
                } else {
                    callback(result: .success(["result": false]))
                }
            }
        } else if message.name == MessageName.requestPermissions.rawValue {
            let permission = (try? JSONDecoder().decode(Parameters.self, from: data))?.permission ?? .camera
            if permission == .camera {
                AVCaptureDevice.requestAccess(for: .video) { (result) in
                    DispatchQueue.main.async {
                        if result {
                            self.callback(result: .success(["result": true]))
                        } else {
                            self.callback(result: .success(["result": false]))
                        }
                    }
                }
            }
        }
    }

}
