require 'rubygems'

require 'require_relative'
require_relative 'trade/test/ModelTests/test_require'

require 'rspec/core/rake_task'
require 'rcov/rcovtask'
require 'rake/testtask'

task :default => [:models_rcov]

def file_list(t)
  t.test_files = FileList["trade/test/ModelTests/*_test.rb", "trade/test/ModelTests/*_spec.rb"]
end

def file_list_controller(t)
  t.test_files = FileList["trade/test/ControllerTests/*_test.rb"]
end

def exclude_controller(t)
  t.rcov_opts << "--exclude \"/gems/,/models/,spec,/helpers/,/*Tests/,init.rb,require.rb\""
end

def exclude(t)
  t.rcov_opts << "--exclude \"/gems/,/controllers/,spec,/helpers/,/*Tests/,init.rb,require.rb\""
end

def lib(t)
  t.libs << "trade/test/ModelTests"
end

def lib_controller(t)
  t.libs << "trade/test/ControllerTests"
end

Rcov::RcovTask.new :models_rcov do |t|
  lib(t)
  file_list(t)
  exclude(t)
end

Rcov::RcovTask.new :models_missing do |t|
  lib(t)
  file_list(t)
  exclude(t)
  t.rcov_opts << "--threshold 50"
end

Rake::TestTask.new :models_test do |t|
  lib(t)
  t.test_files = FileList["trade/test/ModelTests/*_test.rb"]
end

RSpec::Core::RakeTask.new :models_rspec do |t|
  directory = File.join(File.dirname(__FILE__), '/trade/test/ModelTests')

  t.rspec_opts = "-I#{directory}"
  t.pattern = Dir["trade/test/ModelTests/*_spec.rb"]
end

Rake::TestTask.new :controllers_test do |t|
  lib_controller(t)
  t.test_files = FileList["trade/test/ControllerTests/*_test.rb"]
end

Rcov::RcovTask.new :controllers_rcov do |t|
  lib_controller(t)
  file_list_controller(t)
  exclude_controller(t)
end