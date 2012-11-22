class Alert
  attr_accessor :title, :message, :error

  def self.create(title, message, error)
    alert = Alert.new
    alert.title = title
    alert.message = message
    alert.error = error

    alert
  end

  def error?
    self.error
  end
end