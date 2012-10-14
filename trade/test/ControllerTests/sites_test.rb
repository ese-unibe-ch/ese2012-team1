require 'rubygems'
require 'require_relative'
require 'test/unit'
require 'helper'
require 'rack/test'

require 'test_helper'

ENV['RACK_ENV'] = 'test'

require_relative '../../app/controllers/sites'
require_relative '../../app/models/user'

class SitesTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Controllers::Sites
  end

  describe 'Simple Tests' do
    class TestApp < Controllers::Sites
      configure do
        TestHelper.load
      end
    end

    it 'post /organisation/switch should change session[:account]' do
      users = TestHelper.get_users

      org = users[:homer].create_organisation("founding.inc", "founds things", "../images/users/default_avatar.png")

      session = { :user => users[:homer].id, :auth => true, :account => users[:homer].id  }
      post "/organisation/switch", { :organisation => "founding.inc" }, 'rack.session' => session

      assert(session[:account] == org.id, "Should have id #{org.id} but had #{session[:account]}")
    end
  end
end