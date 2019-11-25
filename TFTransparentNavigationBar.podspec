#
# Be sure to run `pod lib lint TFTransparentNavigationBar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "TFTransparentNavigationBar"
  s.version          = "0.7.0"
  s.summary          = "Custom transition between controllers in UINavigationController that makes navigation bar transparent on specified controllers."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                        Custom transition between controllers in UINavigationController that makes navigation bar transparent on specified controllers. It solves problem with making navigation bar translucent on one controller and non-translucent on another and vice versa.
                       DESC

  s.homepage         = "https://github.com/thefuntasty/TFTransparentNavigationBar"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Ales Kocur" => "ales@thefuntasty.com", "Tom Kraina" => "me@tomkraina.com" }
  s.source           = { :git => "https://github.com/thefuntasty/TFTransparentNavigationBar.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'TFTransparentNavigationBar' => ['Pod/Assets/*.png']
  }

end
