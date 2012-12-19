module Helpers
  def before_for_user_authenticated
    redirect "/" unless session[:auth]

    common_before

    error_redirect("No valid Account ID", "The given account ID could not be found,", !DAOAccount.instance.account_exists?(session[:account]), "/home")
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

    error_redirect("Not your Item", "You can only edit your own items.", !DAOItem.instance.fetch_item(params[:id]).owner.id == session[:account], "/items/my/all")
  end

  def before_for_item_interaction
    before_for_user_authenticated

    error_redirect("No valid Item ID", "The requested item id could not be found.", !DAOItem.instance.item_exists?(params[:id]), "/items/my/all")
  end

  def before_for_admin
    before_for_user_authenticated

    account = DAOAccount.instance.fetch_account(session[:account])
    user = DAOAccount.instance.fetch_account(session[:user])

    redirect "/home" if session[:user] == session[:account]
    error_redirect("Not an Admin", "You're not an administrator of this Organisation.", !account.is_admin?(user), "/organisation/members")
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
