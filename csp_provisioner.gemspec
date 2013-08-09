# encoding: utf-8

$: << File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'csp_provisioner'
  s.version       = '0.0.0'
  s.authors       = ['Andrew Dally']
  s.email         = ['adally@ownyourinfo.com']
  s.homepage      = 'https://ownyourinfo.com'
  s.summary       = %q{The Java dependencies required to provision clouds as ruby modules}
  s.description   = %q{Wraps the libraries used by peackeeper in his CSP example https://github.com/peacekeeper/clouds-starter-packs}

  s.files         = Dir['lib/**/*.rb'] + Dir['lib/**/*.jar']
  s.require_paths = %w(lib)
end