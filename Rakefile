require 'lib/mapkit'
 
spec = Gem::Specification.new do |s|
  s.name = "mapkit"
  s.version = MapKit::VERSION
  s.authors = ["Vincent Landgraf"]
  s.email = ["vincent.landgraf@inovex.de"]
  s.homepage = "http://github.com/threez/mapkit"
  s.summary = "MapKit helps rendering tiles for google maps"
  s.description = "MapKit is an set of helpers to assist building tiles for
  the google maps web client"
  
  s.add_dependency('httparty', '>= 0.5.2')
  s.add_dependency('gd2', '>= 1.1.1')
  
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
 
  s.platform = Gem::Platform::RUBY
 
  s.required_rubygems_version = ">= 1.3.5"
 
  s.files = Dir.glob("lib/**/*") + %w(LICENSE README.markdown)
  s.executables = []
  s.require_path = 'lib'
end
 
begin
  require 'spec/rake/spectask'
rescue LoadError
  task :spec do
    $stderr.puts '`gem install rspec` to run specs'
  end
else
  desc "Run specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = %w(-fs --color)
    t.warning = false
  end
end
 
begin
  require 'rake/gempackagetask'
rescue LoadError
  task(:gem) { $stderr.puts '`gem install rake` to package gems' }
else
  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.gem_spec = spec
  end
  task :gem => :gemspec
end
 
desc "install the gem locally"
task :install => :package do
  sh %{gem install pkg/#{spec.name}-#{spec.version}}
end
 
desc "create a gemspec file"
task :gemspec do
  File.open("#{spec.name}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end
 
task :package => :gemspec
task :default => [:spec, :gemspec]