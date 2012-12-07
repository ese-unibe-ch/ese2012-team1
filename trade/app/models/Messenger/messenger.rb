require 'singleton'

module Models
  # This class is the global messenger.
  # It holds all MessageBoxes (identified by user_id).
  # It is implemented as a Singleton.
  #
  # Responsibility:
  # Control of all MessageBoxes
  # Control of sending and receiving messages

  class Messenger
    include Singleton

    attr_accessor :message_boxes

    def initialize
      self.message_boxes = Hash.new
    end

    ##
    #
    # Create a new Conversation between two or more users.
    # Params: from    : Integer (User ID)
    #         to      : Array[Integer] (User IDs)
    #         subject : String
    #         message : String
    #  Add Conversation to subscribers MessageBox
    #
    ##
    def new_message(from, to, subject, message)

    end

    ##
    #
    # Answer to a Message in a Conversation to all (ore some) users in a conversation.
    # Params: from    : Integer (User ID)
    #         to      : Array[Integer] (User IDs)
    #         subject : String
    #         message : Message
    #         conv_id : Integer
    #         mess_id : Integer
    #  Add message to conversation
    #
    ##
    def answer_message(from, to, subject, message, conv_id, mess_id)

    end

    ##
    #
    # Get MessageBox of user.
    # Params: user_id : Integer (User ID)
    #
    ##
    def get_message_box(user_id)

    end


    ##
    #
    # Create MessageBox for User with ID user_id.
    # Params: user_id : Integer (User ID)
    #
    ##
    def register(user_id)

    end


    ##
    #
    # Delete MessageBox for User with ID user_id.
    # Params: user_id : Integer (User ID)
    #
    ##
    def unregister(user_id)

    end

  end

end