#
# Be sure to run `pod lib lint CometChatUIKitSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CometChatUIKitSwift'
  s.version          = '4.3.9'
  s.summary          = 'CometChat Swift UI Kit is a collection of custom UI Components'
  s.description      = 'The UIKit designed to build chat & calling features in your application. The UI Kit is developed to keep developers in mind and aims to reduce development efforts significantly'

  s.homepage         = 'https://www.cometchat.com'
  s.license          = { :type => 'MIT', :file => 'License.md' }
  s.author           = { 'suryanshbisen' => 'suryansh.bisen@cometchat.com' }
  s.source           = { :http => 'https://library.cometchat.io/ios/v4.0/xcode15/CometChatUIKitSwift_4_3_9.zip'}
  s.vendored_frameworks = 'CometChatUIKitSwift.xcframework'
  s.resource_bundles = {'CometChatUIKitSwift' => ['CometChatUIKitSwift.xcframework/PrivacyInfo.xcprivacy']}

  s.swift_version    = '5.0'
  s.dependency 'CometChatSDK', '4.0.48'
  s.ios.deployment_target = '13.0'



end
