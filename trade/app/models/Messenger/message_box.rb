require 'conversation'
require 'message'

module Models
  # This class implements the MessageBox for Users.
  # It holds all conversations (identified by id).
  #
  # Responsibility:
  # Controlling of Message Reading (mark as Read)
  # Observes all Conversations that are in the MessageBox

  class MessageBox
    attr_accessor :conversations, :owner, :message_tree

    ##
    #
    # Create a new MessageBox for User with ID user_id.
    # Params: user_id : Integer (User ID)
    #
    ##
    def create(user_id)
      self.conversations = Hash.new
      self.owner = user_id
      self.message_tree = Hash.new
    end

    ##
    #
    # Add Conversation to Users MessageBox.
    # Params: conversation : Conversation
    #
    ##
    def add_conversation(conversation)

    end

    ##
    #
    # Check if Message was already read by User.
    # Params: conv_id : Integer (Conversation ID)
    #         mess_id : Integer (Message ID)
    #
    ##
    def read?(conf_id, mess_id)

    end

    ##
    #
    # Counting number of new Messages.
    #
    ##
    def new_messages_count

    end

    ##
    #
    # Check if there are unread Messages.
    #
    ##
    def new_messages?
      self.new_messages_count == 0 ? false : true
    end

    ##
    #
    # Counting number of all Messages.
    #
    ##
    def messages_count

    end

  end

end