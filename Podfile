source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

target 'Neuron' do
  use_frameworks!
  inhibit_all_warnings!

  pod 'AppChainSwift', git: "https://github.com/cryptape/appchain-swift", tag: "v0.19.5"
  pod 'web3swift', git: 'https://github.com/matterinc/web3swift', tag: '1.1.10'
  pod 'RealmSwift'
  pod 'KeychainSwift'

  pod 'Alamofire'
  pod 'Alamofire-Synchronous'
  pod 'SensorsAnalyticsSDK', git: "https://github.com/sensorsdata/sa-sdk-ios", branch: "v1.10.15"

  pod 'PlainPing'
  pod 'LYEmptyView'
  pod 'SDWebImage'
  pod 'IQKeyboardManagerSwift'
  pod 'EFQRCode'
  pod 'RSKPlaceholderTextView', "~> 4.0.0"
  pod 'Toast-Swift', "~> 4.0.0"
  pod 'PullToRefresher', "~> 3.1"
  pod 'IGIdenticon', "~> 0.6"
  pod 'SCLAlertView'
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
