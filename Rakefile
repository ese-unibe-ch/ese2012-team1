require 'rubygems'

require 'require_relative'
require_relative 'trade/test/ModelTests/test_require'

require 'rspec/core/rake_task'
require 'rcov/rcovtask'
require 'rake/testtask'

task :default => [:models]

Rcov::RcovTask.new :models do |t|
  t.libs << "trade/test/ModelTests"
  t.test_files = FileList["trade/test/ModelTests/*_spec.rb", "trade/test/ModelTests/*_test.rb", "require.rb"]
  #t.rcov_opts << "--threshold 50"
  t.rcov_opts << "--exclude /gems/"
  t.rcov_opts << "--text-report --exclude \"/controllers/,spec,/helpers/,/*Tests/\""
end

#Rake::TestTask.new :default do |t|
#  t.verbose = true
#  t.test_files = FileList['system_test.rb']
#end

#RSpec::Core::RakeTask.new do |t|
#  t.pattern = Dir['**/*_spec.rb']
#end
