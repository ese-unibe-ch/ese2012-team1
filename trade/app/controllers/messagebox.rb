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

          session[:navigation].get_selected.select_by_name("messagebox")
          session[:navigation].get_selected.subnavigation.select_by_name("send message")

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

          session[:navigation].get_selected.select_by_name("messagebox")
          session[:navigation].get_selected.subnavigation.select_by_name("news")

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

          session[:navigation].get_selected.select_by_name("messagebox")
          session[:navigation].get_selected.subnavigation.select_by_name("conversations")

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

          session[:navigation].get_selected.select_by_name("messagebox")
          session[:navigation].get_selected.subnavigation.select_by_name("conversations")

          conversation = Messenger.instance.conversations.fetch(params[:conversation_id].to_s)
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

          message = "<h1>You have send:</h1> <br><br>"

          message += "To: "

          receivers = Array.new
          params.each do |key, user_id|
            receivers.push(user_id.to_i) if (key.include?("hidden"))
          end

          if (receivers.size == 0)
            session[:alert] = Alert.create("", "You have not entered any receivers", true)
            redirect '/messagebox/send'
          end

          message +=  receivers.join(",")
          puts receivers.join(",")

          message += "<br>"
          message += "Subject: " + params[:subject] + "<br>"
          message += "Message: " + params[:message] + "<br>"

          Messenger.instance.new_message(session[:user], receivers, params[:subject], params[:message])

          message
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

        post '/messagebox/reply' do
          before_for_user_authenticated

          session[:navigation].get_selected.select_by_name("messagebox")
          session[:navigation].get_selected.subnavigation.select_by_name("send message")

          if params[:conversation_id] == nil
            #TODO ERROR
          end

          conversation = Messenger.instance.conversations.fetch(params[:conversation_id].to_s)

          if conversation == nil
            #TODO ERROR
          end

          haml :'mailbox/reply', :locals => { :conversation => conversation, :message_id => params[:message_id] }
        end

        ##
        #
        # TODO: add description
        #
        ##
        get '/users' do
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
    end
end