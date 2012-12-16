module Helpers

  ##
  #
  # Redirects to set page if there is an Error
  #
  # Params: title       : String (Error Title)
  #         message     : String (Error message)
  #         error       : boolean (Statement to check for possible error)
  #         redirect_to : String (URI to Redirect)
  #
  ##
  def error_redirect(title, message, error, redirect_to)
    if  session[:alert].nil?
      session[:alert] = Alert.create(title, message, true) if error
      redirect redirect_to if !session[:alert].nil? && session[:alert].error
    end
  end

end