##
#
# A Message stores a single message
#
##

class Message
  @@message_count = 1

  #unique id of the message
  attr_reader :message_id

  #message itself
  attr_accessor :message
  #sender of the message
  attr_accessor :sender
  #date when the message was created
  attr_accessor :date
  #subject of the message
  attr_accessor :subject
  #message id of the message this message replies to
  attr_accessor :reply_to
  #depth of the message indicating how deep this message is in the message tree
  attr_accessor :depth
  #receivers of this message
  attr_accessor :receivers

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
  # ==== Parameters
  #
  # +from+:: sender (can't be nil)
  # +to+:: receiver as Array
  # +subject+:: subject of the message (can't be nil)
  # +date+:: date of the message as Time (can't be nil)
  # +message+:: the message itself (can't be nil and can't be an empty string)
  # +reply_to+:: id of the message this message replies to (must be nil or positive integers)
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
  # Returns true if the user is a receiver
  # false otherwise.
  #
  # === Parameters
  #
  # +user_id+:: id of the user that shall be checked
  #
  ##

  def is_receiver?(user_id)
    receivers.one? { |receiver| receiver.to_s == user_id.to_s }
  end

  ##
  #
  # Checks if a given user is the sender
  # of this message.
  #
  # Returns true if the user is the sender
  #
  # === Parameters
  #
  # +user_id+:: id of the user to be checked
  #
  ##

  def is_sender?(user_id)
    user_id.to_s == self.sender.to_s ? out = true : out = false
    return out
  end
end