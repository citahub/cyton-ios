//
//  CKBViewController.swift
//  Neuron
//
//  Created by James Chen on 2018/12/07.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

/// CKB Support PoC.
class CKBViewController: UIViewController {
    private let rpcClient = CKB.RPCClient(url: URL(string: "http://localhost:8114")!)
}
