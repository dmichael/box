# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'box/version'

Gem::Specification.new do |spec|
  spec.name          = 'box-com'
  spec.version       = Box::VERSION
  spec.authors       = ['David Michael']
  spec.email         = ['david.michael@giantmachines.com']
  spec.summary       = %q{Write a short summary. Required.}
  spec.description   = %q{Write a longer description. Optional.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = %w{
    Gemfile
    LICENSE.txt
    README.md
    Rakefile
    lib
    lib/box.rb
    lib/box/authorization.rb
    lib/box/client.rb
    lib/box/exceptions.rb
    lib/box/file.rb
    lib/box/folder.rb
    lib/box/item.rb
    lib/box/session.rb
    lib/box/version.rb
  }

  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_dependency 'memoist', '0.9.3'
  spec.add_dependency 'mechanize', '2.7.2'
  spec.add_dependency 'faraday', '~> 0.9.0'
  spec.add_dependency 'faraday_middleware', '0.9.1'
  spec.add_dependency 'addressable', '<= 2.2.4'
  spec.add_dependency 'hashie'
  spec.add_dependency 'oauth2', '~> 0.9.3'
  spec.add_dependency 'colorize'
end
