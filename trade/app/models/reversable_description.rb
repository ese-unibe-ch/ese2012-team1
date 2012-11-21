#
# Saves all changes of a description. You can choose which
# version you want to have displayed.
#

class ReversableDescription
  attr_accessor :descriptions #Array: All descriptions

  def initialize
    self.descriptions = Array.new
    @version = -2
  end

  def show
    return "" if self.descriptions.size == 0

    self.descriptions[@version]
  end

  def show_version(version)
    fail "Can't show negative version" if version < 0
    fail "Version must be a positive integer" unless version.to_s =~ /^[0-9]+$/
    fail "This version of a description does not exist"  unless descriptions.size >= version-1

    self.descriptions[version-1]
  end

  def set_version(active_version)
    fail "Version must be a positive integer" unless version.to_s =~ /^[0-9]+$/
    fail "Can't set negative version" if active_version < 0
    fail "This version of a description does not exist" unless descriptions.size >= active_version

    @version = active_version-1
  end

  def version
    @version + 1
  end

  def add(description)
    fail "Description has to be defined" if (description.nil?)

    descriptions.push(description)
    @version = descriptions.size - 1
  end

  def traverse
    version = 1
    self.descriptions.each do |description|
      yield version, description
      version += 1
    end
  end
end