module Models
  ##
  #
  # Saves all changes of a description. You can choose which
  # version you want to have displayed.
  #
  ##

  class ReversableDescription
    #Array of all descriptions
    attr_accessor :descriptions

    ##
    #
    # Creates the array that saves all descriptions
    #
    # +version+:: the current description
    #
    ##
    def initialize
      self.descriptions = Array.new
      @version = -2 #-2 inidcates that there is now description right after the creation
    end

    ##
    #
    # Shows the current description
    #
    ##
    def show
      return "" if self.descriptions.size == 0

      self.descriptions[@version]
    end

    ##
    #
    # Shows any description in the description array
    #
    # === Parameters
    #
    # +version+:: determines which description you want to see
    #
    ##
    def show_version(version)
      fail "Can't show negative version" if version < 0
      fail "Version must be a positive integer" unless version.to_s.is_positive_integer?
      fail "This version of a description does not exist"  unless descriptions.size >= version-1

      self.descriptions[version-1]
    end

    ##
    #
    # Sets the current description to any description from the
    # description array
    #
    # === Parameters
    #
    # +active_version+:: the new current description
    #
    ##
    def set_version(active_version)
      fail "Version must be a positive integer" unless version.to_s.is_positive_integer?
      fail "Can't set negative version" if active_version < 0
      fail "This version of a description does not exist" unless descriptions.size >= active_version

      @version = active_version-1
    end

    ##
    #
    # Returns which version the current description
    #
    ##
    def version
      @version + 1
    end

    ##
    #
    # Adds a new description to the description array.
    # This description will be the new current description.
    # This description can't be nil.
    #
    # === Parameters
    #
    # +description+:: the new description
    #
    ##
    def add(description)
      fail "Description has to be defined" if (description.nil?)

      descriptions.push(description)
      @version = descriptions.size - 1
    end

    ##
    #
    # Travers all descriptions and its
    # versions
    #
    # === Examples
    #
    #   reversable_description.traverse do |version, description|
    #     puts "This is #{description} and has version #{version}"
    #   end
    #
    ##
    def traverse
      version = 1
      self.descriptions.each do |description|
        yield version, description
        version += 1
      end
    end
  end
end