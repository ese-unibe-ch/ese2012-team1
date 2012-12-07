require 'observer'

class Conversation
  include Observable
  @@conversations_count = 1

  attr_reader :conversation_id, :messages
  attr_accessor :subscribers

  def initialize
    @conversation_id = @@conversations_count
    @@conversations_count += 1

    @messages = Array.new
    @subscribers = Array.new
  end

  #
  # Params:
  # subscribers : all ids of users that are subscribed to this conversation
  #

  def self.create(subscribers)
    fail "should have subscribers" if (subscribers.nil?)
    fail "all subscribers should be existing users" unless (users_exist?(subscribers))

    conversation = Conversation.new

    conversation.subscribers = subscribers

    conversation
  end

  def self.users_exist?(users_id)
    users_id.all? { |user_id| System.instance.account_exist?(user_id) }
  end

  def add_message(message)
    fail "Message needs id" unless message.respond_to?(:id)
    fail "Message should respond to reply_to" unless message.respond_to?(:reply_to)

    index = message.reply_to.nil? ? messages.size-1 : @messages.find_index { |message_replied| message_replied.id == message.reply_to }
    @messages.insert(index+1, message)
    changed
    notify_observers self, message.id
  end

  def count_messages
    @messages.size
  end
end