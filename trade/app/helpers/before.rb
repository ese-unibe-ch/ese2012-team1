module Helpers
  def before_for_user_authenticated
    redirect "/" unless session[:auth]
    common_before

    if (session[:navigation].nil?)
      session[:navigation] = Navigations.new.build
    end

    redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
  end

  def before_for_user_not_authenticated
     common_before

    if (session[:navigation].nil?)
      session[:navigation] = Navigations.new.build
    end
  end

  def common_before
    @error = Hash.new
    response.headers['Cache-Control'] = 'public, max-age=0'
  end
end
