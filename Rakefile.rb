$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'construct'
require 'find'
 
# Don't include resource forks in tarballs on Mac OS X.
ENV['COPY_EXTENDED_ATTRIBUTES_DISABLE'] = 'true'
ENV['COPYFILE_DISABLE'] = 'true'
 
# Gemspec
construct_gemspec = Gem::Specification.new do |s|
  s.rubyforge_project = 'construct'
 
  s.name = 'construct'
  s.version = Construct::APP_VERSION
  s.author = Construct::APP_AUTHOR
  s.email = Construct::APP_EMAIL
  s.homepage = Construct::APP_URL
  s.platform = Gem::Platform::RUBY
  s.summary = 'Extensible, persistent, structured configuration for Ruby.'
 
  s.files = FileList['{lib}/**/*', 'LICENSE', 'README'].to_a
  s.require_path = 'lib'
  s.has_rdoc = true
 
  s.required_ruby_version = '>= 1.8.5'
end
 
Rake::GemPackageTask.new(construct_gemspec) do |p|
  p.need_tar_gz = true
end
 
Rake::RDocTask.new do |rd|
  rd.main = 'Construct'
  rd.title = 'Construct'
  rd.rdoc_dir = 'doc'
 
  rd.rdoc_files.include('lib/**/*.rb')
end
 
desc "install Construct"
task :install => :gem do
  sh "gem install #{File.dirname(__FILE__)}/pkg/construct-#{Construct::APP_VERSION}.gem"
end
