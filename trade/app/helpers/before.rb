module Helpers
  def before_for_user_authenticated
    redirect "/" unless session[:auth]
    response.headers['Cache-Control'] = 'public, max-age=0'

    if (session[:navigation].nil?)
      session[:navigation] = Navigations.new.build
    end

    redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
  end

  def before_for_user_not_authenticated
    response.headers['Cache-Control'] = 'public, max-age=0'

    if (session[:navigation].nil?)
      session[:navigation] = Navigations.new.build
    end
  end
end
