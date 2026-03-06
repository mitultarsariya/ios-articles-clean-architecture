platform :ios, '18.0'
use_frameworks!
inhibit_all_warnings!

target 'ArticlesApp' do

  # Networking
  pod 'Alamofire',                      '~> 5.9'
  pod 'AlamofireNetworkActivityIndicator', '~> 3.1'

  # Image Loading
  pod 'Kingfisher',                     '~> 8.1'

  # Caching
  pod 'Cache',                          '~> 6.0'

  # Logging
  pod 'XCGLogger',                      '~> 7.0'

  # Dependency Injection
  pod 'Swinject',                       '~> 2.8'

  # Connectivity
  pod 'ReachabilitySwift',              '~> 5.2'

  # UI / UX
  pod 'Loaf',                           '~> 0.6'
  pod 'FTLinearActivityIndicator',      '~> 1.3'
  pod 'KMNavigationBarTransition',      '~> 1.1'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.0'
    end
  end
end
