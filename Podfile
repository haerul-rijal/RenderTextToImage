# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
use_frameworks!

target 'RenderTextToImage' do
  # Comment the next line if you don't want to use dynamic frameworks

  # Pods for RenderTextToImage
  pod 'RxSwift', '5.1.1'
  pod 'RxCocoa', '5.1.1'
  pod 'Texture', '>=2.0'
  pod 'RxCocoa-Texture'
  pod 'TextureSwiftSupport'
end

post_install do |installer_representation|
  installer_representation.pods_project.build_configurations.each do |config|
      config.build_settings['OTHER_CFLAGS'] = '-Xclang -fcompatibility-qualified-id-block-type-checking'
      config.build_settings['OTHER_CPLUSPLUSFLAGS'] = '-Xclang -fcompatibility-qualified-id-block-type-checking'
  end
  installer_representation.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['SUPPORTS_MACCATALYST'] = 'NO'
      config.build_settings['SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD'] = 'NO'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
    end
  end
end
