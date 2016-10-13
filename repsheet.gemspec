# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'repsheet/version'

Gem::Specification.new do |spec|
  spec.name          = 'repsheet'
  spec.version       = Repsheet::VERSION
  spec.authors       = ['Aaron Bedra']
  spec.email         = ['aaron@aaronbedra.com']

  spec.summary       = 'Repsheet Ruby Library'
  spec.description   = 'Repsheet Ruby Library'
  spec.homepage      = 'https://github.com/repsheet/librepsheet-ruby'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'

  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'redis', '~> 3.0'
  spec.add_dependency 'andand', '~> 1.3'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '0.12'
  spec.add_development_dependency 'rubocop', '~> 0.43'
end
