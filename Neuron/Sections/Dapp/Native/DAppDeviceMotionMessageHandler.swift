//
//  DAppDeviceMotionMessageHandler.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/12.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import WebKit
import CoreMotion

class DAppDeviceMotionMessageHandler: DAppNativeMessageHandler {
    struct Parameters: Decodable {
        let interval: Interval
    }
    enum Interval: String, Decodable {
        case game
        case ui
        case normal
    }
    enum MessageName: String {
        case startDeviceMotionListening
        case stopDeviceMotionListening
    }
    override var messageNames: [String] {
        return [
            MessageName.startDeviceMotionListening.rawValue,
            MessageName.stopDeviceMotionListening.rawValue
        ]
    }
    var motionManager: CMMotionManager?

    override func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        super.userContentController(userContentController, didReceive: message)
        guard let data = try? JSONSerialization.data(withJSONObject: message.body, options: .prettyPrinted) else { return }
        if message.name == MessageName.startDeviceMotionListening.rawValue {
            guard motionManager == nil else {
                self.callback(result: .success([:]))
                return
            }
            let interval: Interval = (try? JSONDecoder().decode(Parameters.self, from: data))?.interval ?? .normal
            let manager = CMMotionManager()
            switch interval {
            case .game:
                manager.gyroUpdateInterval = 0.020
            case .ui:
                manager.gyroUpdateInterval = 0.060
            case .normal:
                manager.gyroUpdateInterval = 0.200
            }
            manager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { [weak self](motion, error) in
                guard let motion = motion else {
                    self?.callback(result: .fail(-1, error?.localizedDescription ?? "监听设备方向失败"))
                    return
                }
                self?.motionDidUpdate(motion: motion)
            })
            motionManager = manager
            callback(result: .success([:]))
        } else if message.name == MessageName.stopDeviceMotionListening.rawValue {
            motionManager?.stopDeviceMotionUpdates()
            motionManager = nil
            callback(result: .success([:]))
        }
    }

    func motionDidUpdate(motion: CMDeviceMotion) {
        let result: [String: Any] = [
            "alpha": motion.attitude.roll,
            "beta": motion.attitude.pitch,
            "gamma": motion.attitude.yaw
        ]
        callback(funcName: "onDeviceMotionChange", result: ["res": result])
    }
}
