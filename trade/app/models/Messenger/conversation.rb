require 'observer'

module Models
  ##
  #
  # A conversation holds all messages belonging to one subject
  # Each conversation has a unique id.
  # A conversation knows all its participants
  # A conversation can be observed (see MessageBox). If a new message is put
  # to it then all observers are notified. The conversation
  # itself and the message_id are then returned.
  # An observer has to implement the method
  # #update(conversation, message_id)
  #
  ##

  class Conversation
    include Observable
    @@conversations_count = 1

    #Unique id to address the Conversation
    attr_reader :conversation_id
    #Messages belonging to this conversation
    attr_reader :messages

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
    # Creates a Conversation and stores its subscribers.
    #
    # === Parameters
    #
    # +subscribers+:: all ids of users that are subscribed to this conversation
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
      users_id.all? { |user_id| DAOAccount.instance.account_exists?(user_id) }
    end

    ##
    #
    # Adds a new message to this conversation
    # If a message has reply_to then this message is stored
    # right behind the message it replies to.
    #
    # === Parameters
    #
    # +message+:: message to be added
    ##

    def add_message(message)
      fail "Message needs id" unless message.respond_to?(:id)
      fail "Message should respond to reply_to" unless message.respond_to?(:reply_to)

      index = @messages.size-1
      unless (message.reply_to.nil?)
        index = @messages.find_index { |message_replied| message_replied.message_id.to_i == message.reply_to.to_i }
        message.depth = @messages.fetch(index).depth+1

        count = 0

        found = @messages[index+1..@messages.size-1].find do |last_message|
          result = last_message.depth < message.depth
          count += 1
          result
        end

        index += count - (found.nil? ? 0 : 1)
      end

      @messages.insert(index+1, message)
      changed
      notify_observers self, message
    end

    ##
    #
    # Count of all messages belonging to this Conversation.
    #
    # Returns count as Integer.
    ##

    def count_messages
      @messages.size
    end

    ##
    #
    # Gets message with message id
    #
    # Return nil if message does not exist
    #
    # === Parameters
    #
    # +message_id+:: id of the message to be fetched
    ##

    def get(message_id)
      messages.detect { |message| message.message_id.to_s == message_id.to_s }
    end

    ##
    #
    # Get the last message
    #
    # Returns a Message
    #
    ##
    def get_last_message
      @messages.fetch(self.count_messages - 1)
    end

    ##
    #
    # Check if user is subscriber of this conversation.
    #
    # Returns true if User with given id is a
    # subscriber, false otherwise.
    #
    # === Parameters:
    #
    # +user_id+:: user id of possible subscriber
    #
    ##
    def has_subscriber?(user_id)
      self.subscribers.include?(user_id.to_i)
    end

    ##
    #
    # Checks if conversation has this message
    # with the given id.
    #
    # Returns true if conversation has message,
    # false otherwise.
    #
    # === Parameters
    #
    # +mess_id+:: id of the message to be checked
    #
    ##
    def has_message?(mess_id)
      found = false
      @messages.each {|m| found = true if m.message_id.to_s == mess_id.to_s}
      return found
    end
  end
end