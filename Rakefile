require 'rake/clean'
require 'rubygems'
require 'rubygems/package_task'
require 'rspec/core/rake_task'

spec = eval(File.read('hs.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end

RSpec::Core::RakeTask.new(:spec)

task :default => [:spec]
