#
# Be sure to run `pod lib lint HPPhotoPrint.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "HPPhotoPrint"
  s.version          = "0.1.0"
  s.summary          = "AirPrint photo printing with preview."
  s.description      = <<-DESC
                       Select paper size, printer, view preview and send to print throught AirPrint.
                       DESC
  s.homepage         = "http://hp.com"
  s.screenshots     = "http://a1.mzstatic.com/us/r30/Purple3/v4/a0/13/56/a0135614-df34-c64a-c943-a01c2340ac85/screen568x568.jpeg", "http://a3.mzstatic.com/us/r30/Purple1/v4/a1/4b/61/a14b61da-9582-3047-94e4-7791ce69a62e/screen568x568.jpeg"
  s.license          = 'MIT'
  s.author           = { "James" => "trask@hp.com" }
  s.source           = { :git => "https://github.com/IPGPTP/hp_photo_print.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = ['Pod/Classes', 'Pod/Libraries/XBPageCurl', 'Pod/Libraries/Reachability']
  s.resource_bundles = {
    'HPPhotoPrint' => ['Pod/Assets/*.png', 'Pod/Classes/*.xib', 'Pod/Classes/*.storyboard']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = ['Foundation', 'UIKit']
  # s.dependency 'AFNetworking', '~> 2.3'
end
