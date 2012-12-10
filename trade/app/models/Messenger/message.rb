class Message
  @@message_count = 1

  attr_reader :message_id

  attr_accessor :message, :sender, :date, :subject, :reply_to, :depth, :receivers

  def initialize
    @message_id = @@message_count
    @@message_count += 1
    self.depth = 0
    self.receivers = Array.new
  end

  ##
  #
  # Creates a new message
  #
  #Params: from : sender
  #        to : receiver (Array)
  #        subject : subject of the message
  #        date : date of the message (Time)
  #        message : the message itself
  #        reply_to : id of the message this message replies to
  #
  ##

  def self.create(from, to, subject, date, message, reply_to)
    fail "sender should be given" if from.nil?
    fail "receiver should be given" if to.nil?
    fail "date should be set" if date.nil?
    fail "message should be set" if message.nil? || message.size == 0
    fail "reply_to must either be nil or positive integer" unless reply_to.nil? || reply_to.to_s.is_positive_integer?

    mes = Message.new

    mes.sender = from
    mes.receivers = to
    mes.subject = subject.nil? ? "" : subject
    mes.date = date
    mes.message = message
    mes.reply_to = reply_to

    mes
  end

  ##
  #
  # Checks if a given user is the receiver
  # of this message.
  #
  # Params: user_id : the id of the user that shall be checked
  #
  ##

  def is_receiver?(user_id)
    receivers.one? { |receiver| receiver.to_s == user_id.to_s }
  end
end