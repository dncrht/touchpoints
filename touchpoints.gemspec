
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "touchpoints/version"

Gem::Specification.new do |spec|
  spec.name          = "touchpoints"
  spec.version       = Touchpoints::VERSION
  spec.authors       = ['Daniel Cruz Horts']

  spec.summary       = %q{Track touchpoints.}
  spec.homepage      = 'https://github.com/dncrht/touchpoints'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'rails', '>= 4'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-rails'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rspec-rails'
end
