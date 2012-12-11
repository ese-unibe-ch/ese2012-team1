require 'observer'

##
#
# A conversation holds all messages belonging to one subject
# Each conversation has a unique id.
# A conversation knows all its participants
# A conversation can be observed. If a new message is put
# to it then all observers are notified. The conversation
# itself and the message_id are then returned.
# An observer has to implement the method
# #update(conversation, message_id)
#
##

class Conversation
  include Observable
  @@conversations_count = 1

  attr_reader :conversation_id, #Unique id to address the Conversation
              :messages         #Messages belonging to this conversation

  attr_accessor :subscribers    #Participants

  def initialize
    @conversation_id = @@conversations_count
    @@conversations_count += 1

    @messages = Array.new
    @subscribers = Array.new
  end

  ##
  #
  # The title of the conversation. This is always the
  # subject of the first message.
  #
  ##

  def title
    fail "There are no messages yet" if self.messages.size == 0

    @messages[0].subject.size == 0 ? "No title" : @messages[0].subject
  end

  ##
  #
  # Creates a Conversation and storing its subscribers.
  #
  # Params:
  # subscribers : all ids of users that are subscribed to this conversation
  #
  ##

  def self.create(subscribers)
    fail "should have subscribers" if (subscribers.nil?)
    fail "all subscribers should be existing users" unless (users_exist?(subscribers))

    conversation = Conversation.new

    conversation.subscribers = subscribers

    conversation
  end

  def self.users_exist?(users_id)
    users_id.all? { |user_id| System.instance.account_exists?(user_id) }
  end

  ##
  #
  # Adds a new message to this conversation
  # If a message has reply_to then this message is stored
  # right behind the message it replies to.
  #
  ##

  def add_message(message)
    fail "Message needs id" unless message.respond_to?(:id)
    fail "Message should respond to reply_to" unless message.respond_to?(:reply_to)

    index = messages.size-1
    unless (message.reply_to.nil?)
      index_reply = @messages.find_index { |message_replied| message_replied.message_id.to_i == message.reply_to.to_i }
      message.depth = @messages.fetch(index_reply).depth+1
    end

    @messages.insert(index+1, message)
    changed
    notify_observers self, message
  end

  ##
  #
  # Count of all messages belonging to this Conversation
  #
  ##

  def count_messages
    @messages.size
  end

  ##
  #
  # Gets message with message id
  # Return nil if message does not exist
  #
  ##

  def get(message_id)
    messages.detect { |message| message.message_id.to_s == message_id.to_s }
  end
end