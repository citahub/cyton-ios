//
//  DAppTakePhotoMessageHandler.swift
//  Cyton
//
//  Created by 晨风 on 2018/11/12.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation

class DAppTakePhotoMessageHandler: DAppNativeMessageHandler, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    override var messageNames: [String] {
        return ["takePhoto"]
    }

    enum Quality: String, Decodable {
        case high
        case normal
        case low
    }

    struct Parameters: Decodable {
        var quality: Quality?
    }

    var quality: Quality?

    override func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        super.userContentController(userContentController, didReceive: message)
        guard let data = try? JSONSerialization.data(withJSONObject: message.body, options: .prettyPrinted) else { return }
        quality = try? JSONDecoder().decode(Parameters.self, from: data).quality ?? .normal

        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self](result) in
            guard let self = self else { return }
            if result {
                let controller = UIImagePickerController()
                controller.delegate = self
                controller.sourceType = .photoLibrary
                controller.allowsEditing = false
                DispatchQueue.main.async {
                    self.webView?.viewController?.present(controller, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "", message: "DApp.DAppTakePhoto.CameraPermissions".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "DApp.DAppTakePhoto.Open".localized(), style: .default, handler: { (_) in
                    let url = URL(string: UIApplication.openSettingsURLString)!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }))
                alert.addAction(UIAlertAction(title: "Common.cancel".localized(), style: .default, handler: { (_) in
                    alert.dismiss(animated: true, completion: nil)
                    self.callback(result: .fail(-1, "DApp.DAppTakePhoto.NoAccess".localized()))
                }))
                DispatchQueue.main.async {
                    self.webView?.viewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else { return }
        let resultImageData: Data
        if quality == .high {
            resultImageData = image.jpegData(compressionQuality: 1.0)!
        } else if quality == .low {
            resultImageData = image.jpegData(compressionQuality: 0.5)!
        } else {
            resultImageData = image.jpegData(compressionQuality: 0.75)!
        }
        let cachesDirectory = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!, isDirectory: true)
        let cachePath = cachesDirectory.appendingPathComponent("\(Date().timeIntervalSince1970).jpeg")
        try? resultImageData.write(to: cachePath)
        callback(result: .success(["imagePath": cachePath.absoluteString]))
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        callback(result: .fail(-1, "Common.Connection.UserCancel".localized()))
    }
}
