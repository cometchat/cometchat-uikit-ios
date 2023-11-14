#
# Be sure to run `pod lib lint CometChatUIKitSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CometChatUIKitSwift'
  s.version          = '4.0.3'
  s.summary          = 'CometChat Swift UI Kit is a collection of custom UI Components'
  s.description      = 'The UIKit designed to build text , chat  features in your application. The UI Kit is developed to keep developers in mind and aims to reduce development efforts significantly'

  s.homepage         = 'https://www.cometchat.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'abhisheksaralaya13' => 'abhishek.saralaya@cometchat.com' }
  s.source           = { :http => 'https://library.cometchat.io/ios/v4.0/xcode15/CometChatUIKitSwift_4_0_3_1.xcframework.zip'}
  s.vendored_frameworks = 'CometChatUIKitSwift.xcframework'

  s.swift_version    = '5.0'
  s.dependency 'CometChatSDK', '4.0.3'

  s.ios.deployment_target = '13.0'



end
