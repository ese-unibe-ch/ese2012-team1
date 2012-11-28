require 'controller_require'

class AuthenticationTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Controllers::Authentication
  end

  describe 'Simple Tests' do
    class TestApp < Controllers::Authentication
      use Controllers::Home
      configure do
        TestHelper.load
      end
    end

    it 'get /login should show login.html' do
      get '/login', {}, 'rack.session' => { :user => nil, :auth => false  }
      assert last_response.ok?
      assert last_response.body.include?('E-Mail:'), "Should ask for name but was\n#{last_response.body}"
      assert last_response.body.include?('Password:'), "Should ask for password but was\n#{last_response.body}"
    end

    it 'post /authenticate should redirect to /home' do
      session =  { :user => nil, :auth => false  }
      post "/authenticate", :username => "homer@mail.ch", :password => 'homer', 'rack.session' => session
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/home'), "Should redirect to /home but was #{last_response.location}"
    end

    it 'post /authenticate with wrong password should show login.hmtl and error message' do
      post "/authenticate", :username => "homer@mail.ch", :password => 'omer', 'rack.session' => { :user => nil, :auth => false  }
      assert last_response.redirect?
      assert last_response.location.include?('/login')
    end

    it 'post /unauthenticate should reset session[:name] and session[:auth] and redirect to /' do
      session =  { :user => 'Homer', :auth => true  }
      post "/unauthenticate", {}, 'rack.session' => session
      assert session[:user] == nil, "Should reset \':user\' to nil but was #{session[:user]}"
      assert !session[:auth], "Should set \'auth\' to false but was #{session[:auth]}"
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location =~ /\/$/
    end
  end
end