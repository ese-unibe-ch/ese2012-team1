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