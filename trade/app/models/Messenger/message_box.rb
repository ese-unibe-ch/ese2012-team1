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
    def self.create(user_id)
      message_box = MessageBox.new
      message_box.conversations = Hash.new
      message_box.owner = user_id
      message_box.message_tree = Hash.new
      message_box
    end

    ##
    #
    # Add Conversation to Users MessageBox.
    # Params: conversation : Conversation
    #
    ##
    def add_conversation(conversation)
      self.conversations.store(conversation.conversation_id, conversation)
      self.add_to_tree(conversation)
    end

    def add_to_tree(conversation)
      conv_id = conversation.conversation_id
      self.message_tree.store(conv_id.to_s, Hash.new)
      conversation.messages.each{ |m| self.message_tree[conv_id.to_s].store(m.message_id.to_s, false) if m.include?(owner.to_s) }
    end

    ##
    #
    # Check if Message was already read by User.
    # Params: conv_id : Integer (Conversation ID)
    #         mess_id : Integer (Message ID)
    #
    ##
    def read?(conv_id, mess_id)
      self.message_tree[conv_id.to_s][mess_id.to_s]
    end

    ##
    #
    # Set Message as Read.
    # Params: conv_id : Integer (Conversation ID)
    #         mess_id : Integer (Message ID)
    #
    ##
    def set_as_read(conv_id, mess_id)
      self.message_tree[conv_id.to_s][mess_id.to_s] = true
    end

    ##
    #
    # Counting number of new Messages.
    #
    ##
    def new_messages_count
      count = 0
      for m_hash in self.message_tree.values
        m_hash.values.each{ |v| count += 1 if !v }
      end
      return count
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
      count = 0
      for m_hash in self.message_tree.values
        m_hash.values.each{ |v| count += 1 }
      end
      return count
    end


    ##
    #
    # Observing conversations.
    #
    ##
    def update(conversation, mess_id)
      conv_id = conversation.conversation_id
      self.message_tree[conv_id.to_s].store(mess_id.to_s, false)
    end

  end

end