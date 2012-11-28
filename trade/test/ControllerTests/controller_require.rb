require 'rubygems'
require "rspec"
require "require_relative"
require 'rack/test'
require 'test/unit'

require_relative "../../../trade/app/require"
require_relative "helper"

require_relative 'helper'
require_relative 'test_helper'

ENV['RACK_ENV'] = 'test'