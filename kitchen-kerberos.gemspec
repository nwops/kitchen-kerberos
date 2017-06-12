# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/kerberos/version'

Gem::Specification.new do |spec|
  spec.name          = "kitchen-kerberos"
  spec.version       = Kitchen::Kerberos::VERSION
  spec.authors       = ["Corey Osman"]
  spec.email         = ["corey@nwops.io"]

  spec.summary       = %q{Adds a kerberos ticket authentication to test-kitchen transport }
  spec.description   = %q{Adds a kerberos ticket authentication to test-kitchen transport}
  spec.homepage      = "https://github.com/nwops/kitchen-kerberos"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "net-ssh-krb", "~> 0.4.0"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
