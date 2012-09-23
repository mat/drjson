# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'drjson/version'

Gem::Specification.new do |gem|
  gem.name          = "drjson"
  gem.version       = Drjson::VERSION
  gem.authors       = ["Matthias Luedtke"]
  gem.email         = ["github@matthias-luedtke.de"]
  gem.description   = %q{Closes abruptly cut-off JSON strings.}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/mat/drjson"

  gem.files         = (`git ls-files`.split($/)).reject{ |path| path =~ /fixtures/}
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
