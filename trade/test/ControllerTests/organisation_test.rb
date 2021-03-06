require 'controller_require'
require_relative '../../app/controllers/organisation'

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

      session = { :user => users[:homer].id, :auth => true, :account => users[:homer].id  }
      post "/organisation/switch", { :account => org.id }, 'rack.session' => session

      assert(session[:account] == org.id, "Should have id #{org.id} but had #{session[:account]}")
    end

    it 'get organisation/create should show page to create an organisation' do
      TestHelper.reload

      session = TestHelper.get_sessions

      get "/organisation/create", {}, 'rack.session' => session[:homer]

      assert last_response.ok?, "#{last_response.body}"
      assert last_response.body.include?("Launch Organisation")
    end
  end
end