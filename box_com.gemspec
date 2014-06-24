# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "box_com"
  spec.version       = '0.0.3'
  spec.authors       = ["David Michael"]
  spec.email         = ["david.michael@giantmachines.com"]
  spec.summary       = %q{Write a short summary. Required.}
  spec.description   = %q{Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = ["Gemfile",
     "LICENSE.txt",
     "README.md",
     "Rakefile",
     "lib",
     "lib/box.rb",
     "lib/box/authorization.rb",
     "lib/box/client.rb",
     "lib/box/exceptions.rb",
     "lib/box/file.rb",
     "lib/box/folder.rb",
     "lib/box/item.rb",
     "lib/box/session.rb",
     "lib/box/version.rb",
     "box_com.gemspec",
     ]
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_dependency "memoist"
  spec.add_dependency "mechanize"
  spec.add_dependency "faraday"
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency "addressable"
  spec.add_dependency "hashie"
  spec.add_dependency "oauth2"
end
