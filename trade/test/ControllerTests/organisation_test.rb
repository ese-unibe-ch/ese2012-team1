require 'rubygems'
require '../../app/require'
require 'test/unit'
require 'helper'
require 'rack/test'

require 'test_helper'

ENV['RACK_ENV'] = 'test'

require_relative '../../app/controllers/organisation'
require_relative '../../app/models/user'

class OrganisationTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Controllers::Organisation
  end

  describe 'Simple Tests' do
    class TestApp < Controllers::Organisation
      configure do
        TestHelper.load
      end
    end

    it 'post /organisation/switch should change session[:account]' do
      TestHelper.reload

      users = TestHelper.get_users

      org = users[:homer].create_organisation("founding.inc", "founds things", "/images/organisations/default_avatar.png")

      session = { :user => users[:homer].id, :auth => true, :account => org.id  }
      post "/organisation/switch", { :account => org.id }, 'rack.session' => session

      assert(session[:account] == org.id, "Should have id #{org.id} but had #{session[:account]}")
    end
  end
end