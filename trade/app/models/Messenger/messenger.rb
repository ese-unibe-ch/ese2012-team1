require 'singleton'

module Models
  ##
  #
  # This class is the global messenger.
  # It holds all MessageBoxes (identified by user_id).
  # It is implemented as a Singleton.
  #
  # === Responsibility
  #
  # Control of all MessageBoxes (see MessageBox).
  # Control conversations (see Conversation)
  # Control of sending and receiving messages (see Message).
  #
  ##

  class Messenger
    include Singleton

    #All messageboxes
    attr_accessor :message_boxes
    #All existing conversations
    attr_accessor :conversations

    def initialize
      self.message_boxes = Hash.new
      self.conversations = Hash.new
    end

    ##
    #
    # Create a new Conversation between two or more users.
    # Add Conversation to subscribed MessageBoxes
    #
    # === Parameters
    #
    # +from+:: id of the sender
    # +to+:: array of the ids of the receivers
    # +subject+:: subject of the message
    # +message:: message itself
    #
    ##
    def new_message(from, to, subject, message)
      rec = to.clone
      subs = to.concat([from])
      conv = Conversation.create(subs)
      time = Time.new
      message = Message.create(from, rec, subject, time, message, nil)

      subs.each{ |s| self.message_boxes[s.to_s].add_conversation(conv)}
      conv.add_message(message)

      self.conversations.store(conv.conversation_id.to_s, conv)
      conv
    end

    ##
    #
    # Answer to a Message in a Conversation to all (ore some) users in a conversation.
    # Adds a new Message to the conversation with +conv_id+.
    #
    # === Parameters
    #
    # +from+:: id of the sender the message is from
    # +to+:: array of ids of the receivers
    # +subject+:: subject of the message
    # +message+:: text of the message
    # +conv_id+:: id of the conversation this answer belongs to
    # +mess_id+:: id of the message this message answers to
    #
    ##
    def answer_message(from, to, subject, message, conv_id, mess_id)
      conv = self.conversations.fetch(conv_id.to_s)
      time = Time.new
      message = Message.create(from, to, subject, time, message, mess_id)
      conv.add_message(message)
    end

    ##
    #
    # Fetches MessageBox of user.
    #
    # === Parameters
    #
    # +user_id+:: id of the user to get message for
    #
    ##
    def get_message_box(user_id)
      self.message_boxes.fetch(user_id.to_s)
    end


    ##
    #
    # Creates MessageBox for User with id +user_id+.
    #
    # === Parameters:
    #
    # +user_id+:: id of the user to create a MessageBox for
    #
    ##
    def register(user_id)
      new_mb = MessageBox.create(user_id)
      self.message_boxes.store(user_id.to_s, new_mb)
    end


    ##
    #
    # Deletes MessageBox for User with ID user_id.
    #
    # === Parameters
    #
    # +user_id+:: id of the user whose MessageBox is to be deleted
    #
    ##
    def unregister(user_id)
      self.message_boxes.delete(user_id.to_s)
    end

    ##
    #
    # Checks if conversation exists.
    #
    # Returns true if conversation exist, false
    # otherwise.
    #
    # === Parameters:
    #
    # +conversation_id+:: id of the conversation to be checked
    #
    ##
    def has_conversation?(conversation_id)
      self.conversations.has_key?(conversation_id.to_s)
    end

    ##
    #
    # Removes all message boxes an conversations
    #
    ##

    def reset
      self.message_boxes = Hash.new
      self.conversations = Hash.new
    end
  end
end