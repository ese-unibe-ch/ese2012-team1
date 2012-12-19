require 'require'

class App < Sinatra::Base

  Haml::Template.options[:escape_html] = true

  use Rack::Protection

  enable :sessions unless ENV['RACK_ENV'] == 'test'

  set :root, File.dirname(__FILE__)
  set :views , "#{absolute_path('/views', __FILE__)}"

  set :public_folder, 'public'
  set :static, true

  #To set Port on Server
  useSecureServer = false
  ##replace_for_port##

  if useSecureServer
    CERT_PATH = '/home/ese2012/certs/'
    webrick_options = {
        :Bind               => "www.jokr.ch",
        :Port               => 443,
        :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
        :SSLEnable          => true,
        :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
        :SSLCertificate     => OpenSSL::X509::Certificate.new( File.open(File.join(CERT_PATH, "www.jokr.ch.cer")).read),
        :SSLPrivateKey      => OpenSSL::PKey::RSA.new( File.open(File.join(CERT_PATH, "www.jokr.ch.key")).read),
        :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ],
        :app                => App
    }
  end

  #To have userfriendly errors set :development true in helpers/error.rb

  #No registration needed
  use Controllers::Home
  use Controllers::Authentication
  use Controllers::Registration

  #Authentication needed
  use Controllers::Search
  use Controllers::ItemCreate
  use Controllers::ItemSites
  use Controllers::UserSites
  use Controllers::AccountEdit
  use Controllers::Organisation
  use Controllers::Messagebox

  #Need Item Id and Item exist
  use Controllers::ItemInteraction

  #Item belong to user needed
  use Controllers::ItemManipulation

  #Admin needed
  use Controllers::OrganisationAdmin

  # Create Timer to reset User Buy Limits at 24:00
  scheduler = Rufus::Scheduler.start_new
  scheduler.cron '0 0 * * *' do
    DAOAccount.instance.reset_all_member_limits
  end

  if useSecureServer
    Rack::Server.start webrick_options
  end
end

App.run! unless ENV['RACK_ENV'] == 'test'
