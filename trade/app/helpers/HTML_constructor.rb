
class String

  ##
  #
  # Surrounds given part of string with <strong></strong> html
  # tags.
  #
  # Example:
  #   string = "hold"
  #   string.boldify("old") # h<strong>old</strong>
  #
  ##

  def boldify(string)
    self.gsub(string, "<strong>#{string}</strong>")
  end

  ##
  #
  # Create a link for the given item.
  #
  # Example:
  #   item = "item"
  #   item.create_link(7) # <a href='/item/7'>item</a>
  #
  ##

  def create_link(item_nr)
    "<a href=\'/item/#{item_nr}\'>#{self}</a>"
  end

end