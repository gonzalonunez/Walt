#
# Be sure to run `pod lib lint Walt.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Walt'
  s.version          = '0.1.2'
  s.summary          = 'A Swift 3 library for creating gifs/videos from a series of images.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Walt is a Swift 3 library for creating gifs/videos from a series of images.
                       DESC

  s.homepage         = 'https://github.com/gonzalonunez/Walt'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'gonzalonunez' => 'hello@gonzalonunez.me' }
  s.source           = { :git => 'https://github.com/gonzalonunez/Walt.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/gonzalo__nunez'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Walt/Source/**/*'
  s.resources = 'Walt/Assets/**/*'

  s.frameworks = 'UIKit', 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'ImageIO', 'MobileCoreServices', 'QuartzCore'
end
