#
#  Be sure to run `pod spec lint DPDraggableButton.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "DPDraggableButton"
  s.version      = "0.1.0"
  s.summary      = "Draggable Button"

  s.description  = <<-DESC
                    Drag or tap the button to trigger gesture event  
                    DESC

  s.homepage     = "https://github.com/HongliYu/DPDraggableButton-Swift"
  s.license      = "MIT"
  s.author       = { "HongliYu" => "yhlssdone@gmail.com" }
  s.source       = { :git => "https://github.com/HongliYu/DPDraggableButton-Swift.git", :tag => "#{s.version}" }

  s.platform     = :ios, "12.0"
  s.requires_arc = true
  s.source_files = "Sources/DPDraggableButton-Swift/*.swift"  
  s.frameworks   = 'UIKit', 'Foundation'
  s.module_name  = 'DPDraggableButton'
  s.swift_version = "5.0"

end

