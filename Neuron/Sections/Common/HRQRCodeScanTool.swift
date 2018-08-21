//
//  XHRQRCodeTool.swift
//  HRScanToolDemp
//
//  Created by haoran on 2018/4/9.
//  Email:  xuhaoran416518@gmail.com
//  Github: https://github.com/CoderHRXu/HRQRCodeScanTool
//  Copyright © 2018年 haoran. All rights reserved.
//

import UIKit
import AVFoundation
import CoreFoundation

public enum HRQRCodeTooError: Int {
    /// 模拟器错误
    case SimulatorError
    /// 摄像头权限错误
    case CamaraAuthorityError
    /// 其他错误
    case OtherError
}

public protocol HRQRCodeScanToolDelegate: NSObjectProtocol {

    /// 识别失败
    ///
    /// - Parameter error: 识别失败
    func scanQRCodeFaild(error: HRQRCodeTooError)

    /// 识别成功
    ///
    /// - Parameter resultStrs: 字符串
    func scanQRCodeSuccess(resultStrs: [String])
}

open class HRQRCodeScanTool: NSObject {

    open static let shared = HRQRCodeScanTool()

    // MARK: - property

    /// 代理
    open weak var delegate: HRQRCodeScanToolDelegate?

    /// 设置是否需要描绘二维码边框 默认true
    open var isDrawQRCodeRect = true

    /// 二维码边框颜色 默认红色
    open var drawRectColor = UIColor.red

    /// 二维码边框线宽 默认2
    open var drawRectLineWith: CGFloat = 2

    /// 黑色蒙版层 默认开启
    open var isShowMask = true

    /// 蒙板层 默认黑色 alpha 0.5
    open var maskColor = UIColor.init(white: 0, alpha: 0.5)

    /// 中心非蒙板区域的宽 默认200
    open var centerWidth: CGFloat = 200

    /// 中心非蒙板区域的宽 默认200
    open var centerHeight: CGFloat = 200

    /// 中心非蒙板区域的中心点 默认Veiw的中心
    open var centerPosition: CGPoint?

    /// 存储layer
    fileprivate var deleteTempLayers = [CAShapeLayer]()

    /// 输入
    fileprivate var inPut: AVCaptureDeviceInput?

    /// 输出
    fileprivate let outPut: AVCaptureMetadataOutput = {
        let outPut = AVCaptureMetadataOutput.init()
        outPut.connection(with: .metadata)
        return outPut
    }()

    /// session
    fileprivate let session: AVCaptureSession = {
        let session = AVCaptureSession.init()
        if session.canSetSessionPreset(.high) {
            session.sessionPreset = .high
        }
        return session
    }()

    fileprivate let preLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init()

    // MARK: - LifeCycle
     override init() {
        super.init()
//        if !checkCameraAuth() {
//            delegate?.scanQRCodeFaild(error: .CamaraAuthorityError)
//            return
//        }
        guard let device = AVCaptureDevice.default(for: .video)  else {
            return
        }
        do {
            inPut = try AVCaptureDeviceInput.init(device: device)
        } catch {
            print(error)
            delegate?.scanQRCodeFaild(error: .OtherError)
        }

        outPut.setMetadataObjectsDelegate(self as AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
        preLayer.session = session

    }

    // MARK: - Public Methods

    /// 开始扫码 结果在delegate方法返回
    ///
    /// - Parameter view: view
    open func beginScanInView(view: UIView) {

        #if targetEnvironment(simulator)
        delegate?.scanQRCodeFaild(error: .SimulatorError)
        return
        #endif
        guard let input = inPut  else {
            return
        }

        if session.canAddInput(input) && session.canAddOutput(outPut) {
            session.addInput(input)
            session.addOutput(outPut)
            // 设置元数据处理类型(注意, 一定要将设置元数据处理类型的代码添加到  会话添加输出之后)
            outPut.metadataObjectTypes = [.ean13, .ean8, .upce, .code39, .code93, .code128, .code39Mod43, .qr]
//            outPut.metadataObjectTypes = [.qr]

        } else {
            // delegate错误回调
            delegate?.scanQRCodeFaild(error: .OtherError)
            return
        }

        // 添加预览图层
        let flag = view.layer.sublayers?.contains(preLayer)
        if flag == false || flag == nil {
            self.preLayer.frame = view.bounds
            view.layer.insertSublayer(preLayer, at: 0)
        }

        // 蒙版层
        if isShowMask {

            let path            = UIBezierPath(rect: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            // 默认view的中心
            var centerPath      = UIBezierPath(rect: CGRect(x: (view.frame.size.width - centerWidth) / 2, y: (view.frame.size.height - centerHeight-64) / 2, width: centerWidth, height: centerHeight))
            if let centerPosition = centerPosition {
                centerPath      = UIBezierPath(rect: CGRect(x: centerPosition.x - centerWidth / 2, y: centerPosition.y - centerHeight / 2, width: centerWidth, height: centerHeight))
            }
            path.append(centerPath.reversing())
            let rectLayer       = CAShapeLayer()
            rectLayer.path      = path.cgPath
            rectLayer.fillColor = maskColor.cgColor
            view.layer.addSublayer(rectLayer)

        }

        // 启动会话
        session.startRunning()

    }

    /// 停止扫描
    open func stopScan() {

        session.stopRunning()
        if let input = inPut {
            session.removeInput(input)
        }
        session.removeOutput(outPut)
        removeShapLayer()
    }

    /// 设置兴趣区域
    ///
    /// - Parameter originRect: 区域
    open func setInterestRect(originRect: CGRect) {

        // 设置兴趣点
        // 兴趣点的坐标是横屏状态(0, 0 代表竖屏右上角, 1,1 代表竖屏左下角)
        let screenBounds        = UIScreen.main.bounds
        let x                   = originRect.origin.x / screenBounds.size.width
        let y                   = originRect.origin.y / screenBounds.size.height
        let width               = originRect.size.width / screenBounds.size.width
        let height              = originRect.size.height / screenBounds.size.height
        outPut.rectOfInterest   = CGRect(x: x, y: y, width: width, height: height)

    }

    // MARK: - PrivateMethods

    /// 添加框框
    ///
    /// - Parameter transformObj: <#transformObj description#>
    fileprivate func addShapeLayers(transformObj: AVMetadataMachineReadableCodeObject) {

        // 绘制边框
        let layer               = CAShapeLayer.init()
        layer.strokeColor       = drawRectColor.cgColor
        layer.lineWidth         = drawRectLineWith
        layer.fillColor         = UIColor.clear.cgColor

        // 创建一个贝塞尔曲线
        let path = UIBezierPath.init()
        var index = 0

        for pointDic in transformObj.__corners {

            let dict            = pointDic as CFDictionary
            let point           = CGPoint.init(dictionaryRepresentation: dict) ?? CGPoint.zero
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
            index += 1

        }
        path.close()
        layer.path              = path.cgPath
        preLayer.addSublayer(layer)
        deleteTempLayers.append(layer)

    }

    /// 移除二维码边框图层
    fileprivate func removeShapLayer() {
        for layer in deleteTempLayers {
            layer.removeFromSuperlayer()
        }
        deleteTempLayers.removeAll()
    }

    /// 检查相机权限
    ///
    /// - Returns: 是否
//    fileprivate func checkCameraAuth() -> Bool {
//
//        let status = AVCaptureDevice.authorizationStatus(for: .video)
//        return status == .authorized
//    }

}

extension HRQRCodeScanTool: AVCaptureMetadataOutputObjectsDelegate {

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        // 移除扫描层
        if isDrawQRCodeRect {
            removeShapLayer()
        }

        var resultStrs = [String]()

        for obj in metadataObjects {

            guard let codeObj = obj as? AVMetadataMachineReadableCodeObject else {
                return
            }

            resultStrs.append(codeObj.stringValue ?? "")
            if isDrawQRCodeRect {
                // obj 中的四个角, 是没有转换后的角, 需要我们使用预览图层转换
                let tempObj = preLayer.transformedMetadataObject(for: codeObj)
                self.addShapeLayers(transformObj: tempObj as! AVMetadataMachineReadableCodeObject)
            }
        }
        delegate?.scanQRCodeSuccess(resultStrs: resultStrs)
        self.stopScan()
    }

}
