source 'https://github.com/CocoaPods/Specs.git'
xcodeproj 'Voco/Voco.xcodeproj'
platform :ios, '8.0'

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['ENABLE_BITCODE'] = 'NO'
		end
	end
end

# ignore all warnings from all pods
inhibit_all_warnings!
pod 'RestKit', :git => 'https://github.com/RestKit/RestKit.git', :tag => 'v0.25.0'
pod 'Reachability',  '~> 3.1.1'
pod 'MBProgressHUD', '~> 0.8'
pod 'UIAlertView+Blocks', :git => 'https://github.com/deepwinter/UIAlertView-Blocks.git'
pod 'M13Checkbox', '~> 1.1.0'
pod 'US2FormValidator', '~> 1.1.2'
pod 'BlocksKit', '~> 2.2.2'
pod 'Stripe', '~> 5.1.4'
pod 'DTCoreText'
pod 'ASImageResize', '~> 1.0.3'
pod 'SDWebImage', '~> 3.7.1'
pod 'RKCLLocationValueTransformer'
pod 'Fabric'
pod 'Crashlytics'
pod 'Mapbox-iOS-SDK', :git => 'https://github.com/deepwinter/mapbox-ios-sdk.git', :branch => 'release'
pod 'ViewDeck', '~> 2.2.11'
pod 'Masonry'
pod 'PKImagePicker', :git => 'https://github.com/deepwinter/PKImagePickerDemo.git'
pod 'Raven'

 
link_with 'Usama Development', 'Aluvi Distributio Alpha', 'Aluvi Distribution Nightly'
