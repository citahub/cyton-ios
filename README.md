# Neuron Wallet (iOS)

[![Travis](https://travis-ci.com/cryptape/neuron-ios.svg?branch=develop)](https://travis-ci.com/cryptape/neuron-ios)
[![Swift](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![AppChain](https://img.shields.io/badge/made%20for-Nervos%20AppChain-blue.svg)](https://appchain.nervos.org)

# Overview

Neuron is an open source blockchain wallet which supports Ethereum and [AppChain](https://docs.nervos.org/#/). It supports most tokens of Ethereum and [AppChain](https://docs.nervos.org/#/), such as ETH, ERC20, ERC721, and also supports most kinds of DApps of Ethereum and [AppChain](https://docs.nervos.org/#/) , such as cryptokitties, Fomo3D, 0xproject...

# Usage

## Private key and address

Neuron is a blockchain wallet that supports both Ethereum and Nervos [AppChain](https://docs.nervos.org/#/), you can use a single private key and address to access your Ethereum and AppChain account. **Neuron never saves your private key directly, you need to input password to sign every transaction. If you forget your private key, Neuron can not find and recover it, so you should save private key (keystore and mnemonic) carefully.**

Neuron supports importing wallet through private key, keystore and mnemonic, and supports exporting keystore.

## Token

Neuron is a blockchain wallet which supports Ethereum, so you can view your ERC20 token balances and tranfer tokens to other accounts. If you can not find certain ERC20 token, you can input contract address to load token information and add to your token list.

Nervos [AppChain](https://docs.nervos.org/#/) is a blockchain solution which includes blockchain kernel CITA, Neuron wallet, blockchain browser [Microscope](https://github.com/cryptape/microscope), cache server [ReBirth](https://github.com/cryptape/re-birth) and SDKs of different programming languages. [AppChain](https://docs.nervos.org/#/) supports Ethereum solidity contract, so all ERC contracts can deploy to AppChain directly.

AppChain is an open source blockchain solution, you can create your blockchain token by yourself and set any name(symbol) you like. All tokens on AppChain can display in Neuron wallet.

## DApp

Neuron is also a DApp browser, which supprts Ethereum and [AppChain](https://docs.nervos.org/#/) DApps. Most popular Ethereum DApps, such as cryptokitties, Fomo3D and 0xproject, can run in Neuron directly. Neuron also supports AppChain DApps, which can be easily migrated from Ethereum. You can get more information about [how to develop an AppChain DApp](https://docs.nervos.org/nervos-appchain-docs/#/quick-start/build-dapp).

## Get Started

* From the project folder, run `pod install`.
* Open `Neuron.xcworkspace` with Xcode.
* Build and run the `Neuron` target.

Neuron supports iOS 10 and newer versions.

## System Requirements

To build Neuron, you'll need:

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

Neuron is open sourced under MIT License.
