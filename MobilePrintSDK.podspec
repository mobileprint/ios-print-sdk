#
# Be sure to run `pod lib lint MobilePrintSDK.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = "MobilePrintSDK"
s.version          = "3.0.10"
s.summary          = "Implements AirPrint with custom layouts, graphical preview, print later queue, and more."
s.description      = <<-DESC
Select paper size, printer, view preview and send to print through AirPrint. Provides for custom layouts, persistent settings, printer availability notifications, print later queue, and more.
DESC
s.homepage         = "https://developers.hp.com/mobile-print-sdk/platform"
s.screenshots     = "https://d3fep8xjnjngo0.cloudfront.net/ios/screenshot1.gif", "https://d3fep8xjnjngo0.cloudfront.net/ios/screenshot2.gif"
s.license          = 'MIT'
s.author           = { "HP Inc." => "print-sdk@hp.com" }
s.source           = { :git => "https://github.com/mobileprint/ios-print-sdk.git", :tag => s.version.to_s }
s.documentation_url = 'http://mobileprint.herokuapp.com'

s.platform     = :ios, '8.0'
s.requires_arc = true

s.source_files = ['Pod/Classes/**/*.{h,m}', 'Pod/Libraries/Reachability/*.{h,m}']

s.resources = ['Pod/*.bundle']
s.resource_bundles  = { 'MPResources' => 
                          ['Pod/Assets/MP.xcassets', 
                           'Pod/Classes/**/*.xib', 
                           'Pod/Classes/*.storyboard'] 
                      }

s.public_header_files = ['Pod/Classes/Public/**/*.h', 'Pod/Libraries/Reachability/*.h']
s.private_header_files = ['Pod/Classes/Private/**/*.h']
s.prefix_header_contents = '#import "MPLogger.h"'

s.frameworks = ['Foundation', 'UIKit']

end
