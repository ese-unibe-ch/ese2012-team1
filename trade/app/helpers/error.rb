module ErrorHandling
  #To get userfriendly error messages set this to false
  set :development, true

  error do
    session[:alert] = Alert.create("Ooops!", "Something went wrong...", true) unless (session[:alert])
    redirect '/home'
  end
end