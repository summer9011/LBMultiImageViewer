#
# Be sure to run `pod lib lint LBMultiImageViewer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LBMultiImageViewer'
  s.version          = '0.1.0'
  s.summary          = 'LBMultiImageViewer is lib for preview images from local album or remote server.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
LBMultiImageViewer is the lib for preview images whatever the image from local album or remote server. It's support to fit very long or very wide image smoothly, and very easy to display large image(the size is over 20M).
                       DESC

  s.homepage         = 'https://github.com/summer9011/LBMultiImageViewer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'summer9011' => 'zhao_li_bo@163.com' }
  s.source           = { :git => 'https://github.com/summer9011/LBMultiImageViewer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'LBMultiImageViewer/Classes/**/*'
  
  # s.resource_bundles = {
  #   'LBMultiImageViewer' => ['LBMultiImageViewer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.frameworks = 'Photos'
  s.dependency 'SDWebImage'

end
