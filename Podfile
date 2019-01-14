source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

target 'Cyton' do
  use_frameworks!
  inhibit_all_warnings!

  pod 'CITA', git: "https://github.com/cryptape/appchain-swift", commit: "249369dec5185e68d274c926c5b68840d6a54b86"
  pod 'web3swift', "~> 2.0.1"
  pod 'RealmSwift'

  pod 'Alamofire'
  pod 'SDWebImage'
  pod 'IQKeyboardManagerSwift'
  pod 'EFQRCode'
  pod 'RSKPlaceholderTextView', "~> 4.0.0"
  pod 'BulletinBoard', git: "https://github.com/alexaubry/BulletinBoard", commit: "7086607d3476cea29cd77a65d13df5c8ed0da52e" # 3.0.0
  pod 'Toast-Swift', "~> 4.0.0"
  pod 'QRCodeReader.swift'

  target 'CytonTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'CytonUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end
