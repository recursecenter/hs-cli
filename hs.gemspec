# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','hs','version.rb'])

spec = Gem::Specification.new do |s|
  s.name = 'hs'
  s.version = HS::VERSION
  s.authors = ['Zach Allaun']
  s.email = ['zach@hackerschool.com']
  s.homepage = 'https://github.com/hackerschool/hs-cli'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Hacker School command line tool'

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('webmock')
  s.add_development_dependency('vcr')

  s.add_runtime_dependency('gli', '2.5.3')
  s.add_runtime_dependency('netrc', '0.7.7')
  s.add_runtime_dependency('git', '1.2.5')
  s.add_runtime_dependency('octokit', '1.22.0')

  s.require_paths = ['lib']
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- {bin/*}`.split("\n").map { |f| File.basename(f) }

end
