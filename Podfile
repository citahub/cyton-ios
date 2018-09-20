source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

target 'Neuron' do
  use_frameworks!
  inhibit_all_warnings!

  pod 'NervosSwift', git: "https://github.com/cryptape/nervos-swift", tag: "v0.17.2"

  pod 'PlainPing'
  pod 'MJRefresh'
  pod 'LYEmptyView'
  pod 'SDWebImage'
  pod 'IQKeyboardManagerSwift'
  pod 'PopupDialog'
  pod 'EFQRCode'
  pod 'RSKPlaceholderTextView'
  pod 'Toast-Swift'
  pod 'RealmSwift'
  pod 'MBProgressHUD'
  pod 'TrustCore', '~> 0.0.7'
  pod 'TrustKeystore', '~> 0.4.1'
  pod 'KeychainSwift'
  pod 'SwiftyJSON', inhibit_warnings: true
  pod 'IGIdenticon'
  pod 'SCLAlertView'
  pod 'Alamofire'
  pod 'Alamofire-Synchronous'

  target 'NeuronTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'NeuronUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end
