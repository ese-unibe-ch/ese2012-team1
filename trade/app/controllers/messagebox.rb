module Controllers
    class Messagebox < Sinatra::Application
        set :views, "#{absolute_path('../views', __FILE__)}"

        get '/messagebox' do
          before_for_user_authenticated

          redirect '/messagebox/news'
        end

        ##
        #
        # Shows the form to send a message to another user.
        # If params[:receiver_id] and params[:receiver_name]
        # are set then this receiver is already set when
        # the page is displayed.
        #
        # Expects:
        # optional: params[:receiver_id] : id of the receiver
        # optional: params[:receiver_name] : name of the receiver
        #
        ##

        get '/messagebox/send' do
          before_for_user_authenticated

          session[:navigation][:selected]  = "messagebox"
          session[:navigation][:subnavigation]  =  "send message"

          receivers = []
          unless (params[:receivers].nil?)
            receivers = params[:receivers].map { |user_id| System.instance.fetch_account(user_id.to_i) }
          end

          haml :'mailbox/send', :locals => { :receivers => receivers }
        end

        ##
        #
        # Displays all new messages
        #
        ##

        get '/messagebox/news' do
          before_for_user_authenticated

          session[:navigation][:selected]  = "messagebox"
          session[:navigation][:subnavigation]  = "news"

          #TODO!
          haml :'mailbox/news'
        end

        ##
        #
        # Displays all conversations of the user
        #
        ##

        get '/messagebox/conversations' do
          before_for_user_authenticated

          session[:navigation][:selected]  = "messagebox"
          session[:navigation][:subnavigation]  = "conversations"

          #TODO!
          haml :'mailbox/conversations'
        end

        ##
        #
        # Displays one specifique conversation
        #
        # Expects:
        # params[:conversation_id] : The id of the conversation to be displayed
        #
        ##

        get '/messagebox/conversation' do
          before_for_user_authenticated

          session[:navigation][:selected]  = "messagebox"
          session[:navigation][:subnavigation] = "conversations"

          error_redirect("No Conversation ID", "There is no Conversation ID set.", params[:conversation_id] == nil || params[:conversation_id] == "", "/messagebox/conversations")
          error_redirect("Wrong Conversation ID", "There is no Conversation with this ID.", !Messenger.instance.has_conversation?(params[:conversation_id]), "/messagebox/conversations")

          conversation = Messenger.instance.conversations.fetch(params[:conversation_id].to_s)
          error_redirect("Not your Conversation", "You can't view a conversation if you're not a Subscriber.", !conversation.has_subscriber?(session[:user]), "/messagebox/conversations")

          Messenger.instance.get_message_box(session[:user]).set_conversation_as_read(conversation.conversation_id)

          haml :'mailbox/conversation', :locals => { :conversation => conversation }
        end

        ##
        #
        # Sends the message
        #
        # Redirects:
        # /messagebox/send if there where no receivers passed
        #
        # Expects:
        # params[:subject] : the subject of the message
        # params[:message] : the actual text message
        # params[:hidden1]...params[hidden100] : user ids of the receivers
        #
        ##
        post '/messagebox/send' do
          before_for_user_authenticated

          @error[:message] = "You have to enter a message" if params[:message].nil? || params[:message].empty?

          unless @error.empty?
            halt       haml :'mailbox/send', :locals => { :receiver_id => params[:receiver_id],
                                                                :receiver_name => params[:receiver_name], }
          end

          receivers = Array.new
          params.each do |key, user_id|
            receivers.push(user_id.to_i) if (key.include?("hidden"))
          end

          if (receivers.size == 0)
            session[:alert] = Alert.create("", "You have not entered any receivers", true)
            redirect '/messagebox/send'
          end

          conversation = Messenger.instance.new_message(session[:user], receivers, params[:subject], params[:message])

          session[:alert] = Alert.create("", "Your message has been sent", false)
          redirect "/messagebox/conversation?conversation_id=#{conversation.conversation_id.to_s}"
        end

        ##
        #
        # Shows the form to reply to a conversation.
        #
        # Expects:
        # params[conversation_id] : id of conversation
        # params[message_id] : id of message or nil
        #
        ##

        get '/messagebox/reply' do
          before_for_user_authenticated

          session[:navigation][:selected]  = "messagebox"
          session[:navigation][:subnavigation] = "send message"

          error_redirect("No Conversation ID", "There is no Conversation ID set.", params[:conversation_id] == nil || params[:conversation_id] == "", "/messagebox/conversations")
          error_redirect("Wrong Conversation ID", "There is no Conversation with this ID.", !Messenger.instance.has_conversation?(params[:conversation_id]), "/messagebox/conversations")

          conversation = Messenger.instance.conversations.fetch(params[:conversation_id].to_s)
          error_redirect("Not your Conversation", "You can't reply to a conversation if you're not a Subscriber.", !conversation.has_subscriber?(session[:user]), "/messagebox/conversations")

          params[:message_id].nil? || params[:message_id] == "" ? mid = nil : mid = params[:message_id]

          if !mid.nil?
            error_redirect("Wrong Message ID", "The Message you try to reply did not exist.", !conversation.has_message?(mid), "/messagebox/conversations")
            message = conversation.get(mid)
            error_redirect("Reply yourself", "You can't reply to a message sent by yourself.", message.sender.to_s == session[:user].to_s, "/messagebox/conversations")
          end

          haml :'mailbox/reply', :locals => { :conversation => conversation, :message_id => mid }
        end

        ##
        #
        # Shows the form to reply to a conversation.
        #
        # Expects:
        # params[conv_id] : id of conversation
        # params[mess_id] : id of message or nil
        #
        ##

        post '/messagebox/reply' do
          before_for_user_authenticated

          @error[:message] = "You have to enter a message" if params[:message].nil? || params[:message].empty?

          unless @error.empty?
            conversation = Messenger.instance.get_message_box(session[:user]).conversations.find { |key, value| key.to_s == params[:conv_id].to_s }
            halt       haml :'mailbox/reply', :locals => { :receiver_id => params[:receiver_id],
                                                          :receiver_name => params[:receiver_name],
                                                          :conversation => conversation[1],
                                                          :message_id => params[:mess_id] }
          end

          receivers = Array.new
          params.each do |key, user_id|
            receivers.push(user_id.to_i) if (key.include?("hidden"))
          end

          if (receivers.size == 0)
            session[:alert] = Alert.create("", "You have removed every receivers", true)
            redirect back
          end

          params[:mess_id] == "" ? mess_id = nil : mess_id = params[:mess_id]
          Messenger.instance.answer_message(session[:user], receivers, params[:subject], params[:message], params[:conv_id], mess_id)

          session[:alert] = Alert.create("", "Your message has been sent", false)
          redirect "/messagebox/conversation?conversation_id=#{params[:conv_id].to_s}"
        end

        ##
        #
        # JSON Interface Address to get Users for new Message
        # params[:query] : string to search in User List
        #
        ##
        get '/messagebox/users/all' do
          content_type :json

          before_for_user_authenticated

          users = Models::System.instance.fetch_all_users_but(session[:account])
          users.delete_if do |user|
            !user.name.include?(params[:query])
          end

          data = users.map { |user| [user.id, user.description, user.avatar] }
          suggestion = users.map { |user| user.name }

          users = {
              "query" => params[:query],
              "suggestions" => suggestion,
              "data" => data
          }

          users.to_json
        end


        ##
        #
        # JSON Interface Address to get Users for reply Message
        # params[:c_id] : id of conversation where user is replying
        # params[:query] : string to search in User List
        #
        # returns only users which are subscribers of the conversation but not the sender
        # hit ? to see all subscribers but the sender
        #
        ##
        get '/messagebox/users/conv' do
          content_type :json

          before_for_user_authenticated
          conv_id = params[:c_id]

          conv = Messenger.instance.conversations.fetch(conv_id.to_s)
          subs = conv.subscribers

          users = Models::System.instance.fetch_all_users_but(session[:account])
          if params[:query] == "?"
            users.delete_if do |user|
              !subs.include?(user.id) || user.id.to_s == session[:user].to_s
            end
          else
            users.delete_if do |user|
              !user.name.include?(params[:query]) || !subs.include?(user.id) || user.id.to_s == session[:user].to_s
            end
          end

          data = users.map { |user| [user.id, user.description, user.avatar] }
          suggestion = users.map { |user| user.name }

          users = {
              "query" => params[:query],
              "suggestions" => suggestion,
              "data" => data
          }

          users.to_json
        end
    end
end