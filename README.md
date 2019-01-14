# Cyton Wallet (iOS)

[![Travis](https://travis-ci.com/cryptape/Cyton-ios.svg?branch=develop)](https://github.com/cryptape/cyton-ios)
[![Swift](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![CITA](https://img.shields.io/badge/made%20for-CITA-blue.svg)](https://www.citahub.com)

# Overview

Cyton is an open source blockchain wallet which supports Ethereum and [CITA](https://www.citahub.com). It supports most tokens of Ethereum and [CITA](https://www.citahub.com), such as ETH, ERC20, ERC721, and also supports most kinds of DApps of Ethereum and [CITA](https://www.citahub.com), such as cryptokitties, Fomo3D, 0xproject...

# Usage

## Private key and address

Cyton is a blockchain wallet that supports both Ethereum and [CITA](https://www.citahub.com), you can use a single private key and address to access your Ethereum and CITA account. **Cyton never saves your private key directly, you need to input password to sign every transaction. If you forget your private key, Cyton can not find and recover it, so you should save private key (keystore and mnemonic) carefully.**

Cyton supports importing wallet through private key, keystore and mnemonic, and supports exporting keystore.

## Token

Cyton is a blockchain wallet which supports Ethereum, so you can view your ERC20 token balances and tranfer tokens to other accounts. If you can not find certain ERC20 token, you can input contract address to load token information and add to your token list.

[CITA](https://www.citahub.com) is a blockchain solution which includes blockchain kernel CITA, Cyton wallet, blockchain browser [Microscope](https://github.com/cryptape/microscope), cache server [ReBirth](https://github.com/cryptape/re-birth) and SDKs of different programming languages. [CITA](https://www.citahub.com) supports Ethereum solidity contract, so all ERC contracts can deploy to CITA directly.

CITA is an open source blockchain solution, you can create your blockchain token by yourself and set any name(symbol) you like. All tokens on CITA can display in Cyton wallet.

## DApp

Cyton is also a DApp browser, which supprts Ethereum and [CITA](https://www.citahub.com) DApps. Most popular Ethereum DApps, such as cryptokitties, Fomo3D and 0xproject, can run in Cyton directly. Cyton also supports CITA DApps, which can be easily migrated from Ethereum. 

## Get Started

* From the project folder, run `pod install`.
* Open `Cyton.xcworkspace` with Xcode.
* Build and run the `Cyton` target.

Cyton supports iOS 10 and newer versions.

## System Requirements

To build Cyton, you'll need:

* Swift 4.2 and later
* Xcode 10 and later
* [CocoaPods](https://cocoapods.org)

# Contributing

We intend for this project to be an open source resource: we are excited to
share our wins, mistakes, and methodology of iOS development as we work
in the open. Our primary focus is to continue improving the app for our users in
line with our roadmap.

The best way to submit feedback and report bugs is to open a GitHub issue.
Please be sure to include your operating system, device, version number, and
steps to reproduce reported bugs. Keep in mind that all participants will be
expected to follow our code of conduct.

# MIT License

Cyton is open sourced under MIT License.
