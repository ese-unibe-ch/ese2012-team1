module Helpers
  def before_for_user_authenticated
    redirect "/" unless session[:auth]

    common_before

    redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
  end

  def before_for_user_not_authenticated
     common_before
  end

  ##
  #
  # Redirects to /error/No_Valid_Item_Id if the id
  # of the item does not exist.
  #
  # Redirects to /error/Not_Your_Item if the item
  # does not belong to the one who wants to
  # manipulate it.
  #
  ##

  def before_for_item_manipulation
    before_for_item_interaction

    redirect "/error/Not_Your_Item" unless DAOItem.instance.fetch_item(params[:id]).owner.id == session[:account]
    #TODO: There is a problem because before is called anyway even if the path is not taken afterwards
  end

  def before_for_item_interaction
    before_for_user_authenticated

    redirect "/error/No_Valid_Item_Id" unless DAOItem.instance.item_exists?(params[:id])
  end

  def before_for_admin
    before_for_user_authenticated

    account = Models::System.instance.fetch_account(session[:account])
    user = Models::System.instance.fetch_account(session[:user])

    redirect "/home" if session[:user] == session[:account]
    redirect "/error/Not_an_Admin" unless account.is_admin?(user)
  end

  def common_before
    @error = Hash.new
    response.headers['Cache-Control'] = 'public, max-age=0'

    if (session[:navigation].nil?)
      Navigations.instance.build
      session[:navigation] = Hash.new
    end
  end
end
