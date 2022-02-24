# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'starkinfra'
  s.version = '0.0.1'
  s.summary = 'SDK to facilitate Ruby integrations with Stark Infra'
  s.authors = 'starkinfra'
  s.homepage = 'https://github.com/starkinfra/sdk-ruby'
  s.files = Dir['lib/**/*.rb']
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.3'
  s.add_dependency('starkbank', '~> 2.6.0')
  s.add_dependency('starkbank-ecdsa', '~> 0.0.5')
  s.add_development_dependency('minitest', '~> 5.14.1')
  s.add_development_dependency('rake', '~> 13.0')
  s.add_development_dependency('rubocop', '~> 0.81')
end