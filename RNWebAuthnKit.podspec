Pod::Spec.new do |s|
  s.name         = "RNWebAuthnKit"
  s.version      = "0.9.10"
  s.summary      = "WebAuthn Client and Authenticator Support Library"

  s.description  = <<-DESC
This library provides you a way to handle W3C Web Authentication API (a.k.a. WebAuthN / FIDO 2.0) easily.
                   DESC

  s.homepage = "https://github.com/Emad-Salah/WebAuthnKit-iOS"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  s.license = { :type => "MIT", :file => "LICENSE" }

  s.author = { "emadkheir" => "emads14@gmail.com" }
  s.social_media_url = "https://twitter.com/SX_Portfolio"

  s.platform = :ios, "10.0"
  s.source = { :git => "https://github.com/Emad-Salah/WebAuthnKit-iOS.git", :tag => "#{s.version}" }

  s.source_files  = "RNWebAuthnKit/Sources/**/*.swift"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  s.framework  = "Foundation", "UIKit", "LocalAuthentication"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  # s.requires_arc = true
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency "PromiseKit", "~> 6.13.1"
  s.dependency "EllipticCurveKeyPair", "~> 2.0"
  s.dependency "KeychainAccess", "~> 4.2.1"
  s.dependency "CryptoSwift", "~> 1.3.8"

  s.swift_version = "4.2"

end
