
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "read2ref/version"

Gem::Specification.new do |spec|
  spec.name          = "read2ref"
  spec.version       = Read2ref::VERSION
  spec.authors       = ["Eric Putnam"]
  spec.email         = ["putnam.eric@gmail.com"]

  spec.summary       = %q{Generate Puppet Strings-style code comments for your Puppet code.}
  spec.homepage      = "https://github.com/eputnam/read2ref"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'puppet-lint'
  spec.add_dependency 'commonmarker'
  spec.add_dependency 'rainbow'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
