require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new(:spec)

desc "Open an irb session preloaded with mapkit"
task :console do
  sh "irb -rubygems -I ./lib -r mapkit"
end

desc 'Default: run specs.'
task :default => :spec
