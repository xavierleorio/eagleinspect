platform :ios, '10.0'
source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

target 'EagleInspect' do
use_frameworks!	
  pod 'DJI-SDK-iOS', '~> 4.13.1'
  pod 'DJIWidget', '~> 1.6.3'
  pod 'DJI-UXSDK-iOS', '~> 4.12'
  pod 'DJIFlySafeDatabaseResource', '~> 01.00.01.17'
  pod 'DJINetworkRTKHelper', '~> 1.1'
end

# Please remove the code below if you don't want to implement the SDK Live Stream feature.
post_install do |installer_representation|
	installer_representation.pods_project.targets.each do |target|
		if target.name == 'DJIWidget'
			target.build_configurations.each do |config|
				config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'ENABLED_LIVESTREAM_AUDIO_INPUT=1']
			end
		end
	end
end
