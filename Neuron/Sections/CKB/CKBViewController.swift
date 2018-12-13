//
//  CKBViewController.swift
//  Neuron
//
//  Created by James Chen on 2018/12/07.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import CKB

/// CKB Support PoC.
class CKBViewController: UIViewController {
    private let rpcClient = APIClient(url: URL(string: "http://localhost:8114")!)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadHeight()
    }
}

extension CKBViewController {
    private func loadHeight() {
        rpcClient.request(method: "get_tip_header") { (json, error) in
            if let error = error {
                print(error)
            }
            guard let json = json else {
                print("Calling CKB RPC failed.")
                return
            }
        }
    }
}
