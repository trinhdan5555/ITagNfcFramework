#
#  Be sure to run `pod spec lint ITagNfcFramework.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "ITagNfcFramework"
  spec.version      = "1.0.0"
  spec.summary      = "Test podspec for ITagNfcFramework"

  spec.homepage     = "https://github.com/trinhdan5555/ITagNfcFramework"

  spec.license      = "MIT"

  spec.author             = { "atrinh" => "atrinh@position-imaging.com" }
  spec.platform     = :ios, "15.0"
  spec.source       = { :git => "https://github.com/trinhdan5555/ITagNfcFramework.git", :tag => "#{spec.version.to_s}" }

  spec.source_files  = "ITagNfcFramework/**/*.{swift,h,m}"
  spec.swift_version = "5.0"

end
