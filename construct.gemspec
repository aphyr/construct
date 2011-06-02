$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'construct'

Gem::Specification.new do |s|
  s.rubyforge_project = 'construct'

  s.name = 'construct'
  s.version = Construct::APP_VERSION
  s.author = Construct::APP_AUTHOR
  s.email = Construct::APP_EMAIL
  s.homepage = Construct::APP_URL
  s.platform = Gem::Platform::RUBY
  s.summary = 'Extensible, persistent, structured configuration for Ruby.'

  s.files = Dir['{lib}/**/*', 'LICENSE', 'README']
  s.require_path = 'lib'
  s.has_rdoc = true

  s.add_development_dependency('bacon', '~> 1.1')

  s.required_ruby_version = '>= 1.8.5'
end
