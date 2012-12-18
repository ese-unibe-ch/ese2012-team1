module Models
  ##
  #
  # This class implements the MessageBox for Users.
  # It holds all conversations (identified by id).
  #
  # === Responsibility
  #
  # Controlling of Message Reading (mark as Read)
  # Observes all Conversations that are in the MessageBox
  #
  ##

  class MessageBox

    attr_accessor :conversations, :owner, :message_tree

    ##
    #
    # Create a new MessageBox for User with ID user_id.
    #
    # === Parameters:
    #
    # +user_id+:: id of the user to own this messagebox
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
    # Find conversation by id
    #
    # Returns Conversation.
    #
    # === Parameters:
    #
    # +conversation_id+:: id of conversation to be fetched.
    #
    ##
    def fetch_conversation(conversation_id)
      self.conversations.fetch(conversation_id.to_s)
    end

    ##
    #
    # Add Conversation to Users MessageBox and add
    # himself as observer.
    #
    # === Parameters
    #
    # +conversation+:: Conversation to be added
    #
    ##

    def add_conversation(conversation)
      conversation.add_observer(self)
      self.conversations.store(conversation.conversation_id.to_s, conversation)
      self.add_to_tree(conversation)
    end

    ##
    #
    # Adds conversation to the message tree.
    #
    # === Parameters
    #
    # +conversation+:: Conversation to be added
    #
    ##

    def add_to_tree(conversation)
      conv_id = conversation.conversation_id
      self.message_tree.store(conv_id.to_s, Hash.new)
      conversation.messages.each{ |m| self.message_tree[conv_id.to_s].store(m.message_id.to_s, false) }
    end

    ##
    #
    # Checks if Message was already read by user.
    #
    # Returns true if message was already read
    # by a user.
    #
    # === Parameters:
    #
    # +conv_id+:: conversation id of the conversation to be checked
    # +mess_id+:: message id of the message to be checked in Conversation belonging to +conv_id+
    #
    ##
    def read?(conv_id, mess_id)
      self.message_tree[conv_id.to_s][mess_id.to_s]
    end

    ##
    #
    # Set Message as read.
    #
    # === Parameters:
    #
    # +conv_id+:: conversation id of the conversation to be checked
    # +mess_id+:: message id of the message to be set as read in Conversation belonging to +conv_id+
    #
    ##
    def set_as_read(conv_id, mess_id)
      self.message_tree[conv_id.to_s][mess_id.to_s] = true
    end

    ##
    #
    # Set all Messages in Conversation as read.
    #
    # === Parameters
    #
    # +conv_id+:: conversation id of the conversation whose messages are to be set as read
    #
    ##
    def set_conversation_as_read(conv_id)
      self.message_tree[conv_id.to_s].each {|k, v| self.set_as_read(conv_id, k) if !v}
    end

    ##
    #
    # Counting number of new Messages.
    #
    # Returns count as Integer.
    #
    ##
    def new_messages_count
      count = 0
      for m_hash in self.message_tree.values
        m_hash.values.each{ |v| count += 1 if !v }
      end
      count
    end

    ##
    #
    # Counting new messages for a specific conversation.
    #
    # Returns count as Integer
    #
    # === Parameters
    #
    # +counversation_id+:: id of conversation whose message are to be counted
    #
    ##

    def new_messages_count_for(conversation_id)
      count = 0
      self.message_tree[conversation_id.to_s].values.each do |read|
        count +=1 if !read
      end
      count
    end

    ##
    #
    # Travers over all new messages of the user
    #
    # === Examples
    #
    #   Messenger.instance.travers_new_messages do |message, conversation_id|
    #     puts message.message
    #   end
    #
    ##

    def travers_new_messages
      self.message_tree.each do |conversation_id, message_read|
        message_read.each do |message_id, read|
          message = self.conversations.fetch(conversation_id.to_s).get(message_id.to_s)
          if message.is_receiver?(self.owner)
              yield message, conversation_id unless read
          end
        end
      end
    end

    ##
    #
    # Check if there are unread Messages.
    #
    # Returns true if messagebox has new messages,
    # false otherwise.
    #
    ##
    def new_messages?
      self.new_messages_count == 0 ? false : true
    end

    ##
    #
    # Counts messages in messagebox.
    #
    # Returns count as Integer.
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
    # Counting number of all message in
    # a specific conversation
    #
    # === Parameters
    #
    # +conversation_id+ id of the conversation to count messages of
    #
    ##

    def message_count_for(conversation_id)
      count = 0
      self.message_tree[conversation_id.to_s].values.each do |read|
        count +=1
      end
      count
    end


    ##
    #
    # Observing conversations. Called from Conversation.
    #
    # === Parameters
    #
    # +conversation+:: conversation which was updated
    # +message+:: message that was newly added
    #
    ##
    def update(conversation, message)
      conv_id = conversation.conversation_id

      #Messages from owner of the MessageBox are set as read
      read = message.sender == owner ? true : false;

      #Stores message only if the user is a receiver
      if (message.is_receiver?(owner))
        self.message_tree[conv_id.to_s].store(message.message_id.to_s, read)
      end
    end

  end

end