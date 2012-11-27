class ErrorMessages
  def self.get(name)
    title = name
    msg = ""
    if name == "Not_A_Number"
      msg = "Price should be a number!"
    elsif name == "Not_Enough_Credits"
      msg = "Sorry, but you can't buy this item, because you have not enough credits!"
    elsif name == "No_Valid_Account_Id"
      msg = "Your account id could not be found"
    elsif name == "No_Valid_User"
      msg = "Your email could not be found"
    elsif name == "No_Name"
      msg = "Please enter a name"
    elsif name == "No_Price"
      msg = "Please enter a name"
    elsif name == "No_Description"
      msg = "Please enter a description"
    elsif name == "No_Valid_Item_Id"
      msg = "The requested item id could not be found"
    elsif name == "Choose_Another_Name"
      msg = "The name you chose is already taken, choose another one"
    elsif name == "No_Self_Remove"
      msg = "You can not remove yourself from your organisation"
    elsif name == "Wrong_Activation_Code"
      msg = "The activation code in the URL is not correct.<br />Try with copy and paste the complete URL from the e-mail into your Browser."
    elsif name == "Already_Activated"
      msg = "You've already activated your User Account.<br /><a href=\"/login\" >Go To Login Page</a>"
    elsif name == "Wrong_Limit"
      msg = "You should enter an Integer Value bigger than 0 to set a Limit.<br />Leave field Empty to remove the Limit."
    else
      title = "Not_An_Error"
      msg = "This is a wrong Error Code."
    end

    msg
  end
end