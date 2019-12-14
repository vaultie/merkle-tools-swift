Pod::Spec.new do |spec|

  spec.name         = "MerkleTools"
  spec.version      = "1.0.0"
  spec.summary      = "Merkle tools written in Swift"

  spec.description  = <<-DESC
  This CocoaPods library provide tools to perform actions on Merkle trees. Such as tree generation, proof calculation, proof vaildation and others.
  DESC

  spec.homepage     = "https://github.com/vaultie/merkle-tools-swift"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Nikita Plakhotin" => "nikita.plakhotin@gmail.com" }

  spec.ios.deployment_target = "11.0"
  spec.swift_version = "5.1.2"

  spec.source        = { :git => "https://github.com/vaultie/merkle-tools-swift.git", :tag => "#{spec.version}" }
  spec.source_files  = "MerkleTools/**/*.{h,m,swift}"

end
