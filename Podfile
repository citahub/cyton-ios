source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

target 'Neuron' do
  use_frameworks!
  inhibit_all_warnings!

  pod 'AppChainSwift', git: "https://github.com/cryptape/appchain-swift", tag: "v0.20.5"
  pod 'web3swift', "~> 2.0.1"
  pod 'RealmSwift'

  pod 'Alamofire'
  pod 'SensorsAnalyticsSDK', git: "https://github.com/sensorsdata/sa-sdk-ios", branch: "v1.10.15"
  pod 'SDWebImage'
  pod 'IQKeyboardManagerSwift'
  pod 'EFQRCode'
  pod 'RSKPlaceholderTextView', "~> 4.0.0"
  pod 'BulletinBoard', git: "https://github.com/alexaubry/BulletinBoard", commit: "7086607d3476cea29cd77a65d13df5c8ed0da52e" # 3.0.0
  pod 'Toast-Swift', "~> 4.0.0"
  pod 'QRCodeReader.swift'

  target 'NeuronTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'NeuronUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end
