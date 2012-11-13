require 'date'
require 'pathname'
require 'rake'
require 'rake/clean'
require 'rake/testtask'

$rootdir = Pathname.new(__FILE__).dirname
$gemspec = Gem::Specification.new do |s|
  s.name              = 'hmac-uri'
  s.version           = '0.1.2'
  s.date              = Date.today
  s.authors           = ['Bharanee Rathna']
  s.email             = ['deepfryed@gmail.com']
  s.summary           = 'HMAC signing for urls'
  s.description       = 'OpenSSL based HMAC signing for request urls with shared secret'
  s.homepage          = 'http://github.com/deepfryed/hmac-uri'
  s.files             = Dir['{test,lib}/**/*.rb'] + %w(README.md CHANGELOG)
  s.require_paths     = %w(lib)

  s.add_dependency('addressable')
  s.add_development_dependency('rake')
end

desc 'Generate gemspec'
task :gemspec do
  $gemspec.date = Date.today
  File.open('%s.gemspec' % $gemspec.name, 'w') {|fh| fh.write($gemspec.to_ruby)}
end

Rake::TestTask.new(:test) do |test|
  test.libs   << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task default: :test

desc 'tag release and build gem'
task :release => [:test, :gemspec] do
  system("git tag -m 'version #{$gemspec.version}' v#{$gemspec.version}") or raise "failed to tag release"
  system("gem build #{$gemspec.name}.gemspec")
end
