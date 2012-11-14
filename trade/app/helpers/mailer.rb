require 'rubygems'
require 'require_relative'

require_relative '../models/simple_email_client' unless ENV['RACK_ENV'] == 'test'
require_relative 'render'

##
#
# Generates the Registration E-Mail.
#
##

module Helpers
  class Mailer

    def self.setup
      return self.new()
    end

    ##
    #
    # Method to call for sending the registration e-mail for user with id "userid".
    #
    ##
    def sendRegMail(userid, current_host)
      new_user = Models::System.instance.fetch_account(userid)
      fail "This is an Organisation, not a user" if (new_user.organisation)
      email = new_user.email
      name = new_user.name
      avatar = new_user.avatar
      reg_hash = new_user.reg_hash

      content = generateMailContent(name, avatar, reg_hash, current_host)

      subject = "Welcome to the ESE-Tradingsystem!"
      sendMail(email, content, subject)
    end

    ##
    #
    # Methods to call for sending an e-mail to auction participators with id "userid".
    #
    ##

    def sendWinnerMail(userid, current_host)
      new_user = Models::System.instance.fetch_account(userid)
      if !new_user.organisation
        email = new_user.email
        name = new_user.name
        avatar = new_user.avatar
        mail_text = "Congratulations. You are the winner of the auction. The item is now yours."

        content = generateAuctionMailContent(name, avatar, current_host, mail_text)

        subject = "You're the auction winner!"
        sendMail(email, content, subject)
      end
    end

    def sendLooserMail(userid, current_host)
      new_user = Models::System.instance.fetch_account(userid)
      if !new_user.organisation
        email = new_user.email
        name = new_user.name
        avatar = new_user.avatar
        mail_text = "Unfortunately, another user won the auction. Good luck for your next auction."

        content = generateAuctionMailContent(name, avatar, current_host, mail_text)

        subject = "Sorry, you lost the auction."
        sendMail(email, content, subject)
      end
    end

    def sendLeaderMail(userid, current_host)
      new_user = Models::System.instance.fetch_account(userid)
      if !new_user.organisation
        email = new_user.email
        name = new_user.name
        avatar = new_user.avatar
        mail_text = "Your the actual leader of the auction."


        content = generateAuctionMailContent(name, avatar, current_host, mail_text)

        subject = "You're the current leader!"
        sendMail(email, content, subject)
      end
    end

    def sendOutbidMail(userid, current_host)
      new_user = Models::System.instance.fetch_account(userid)
      if !new_user.organisation
        email = new_user.email
        name = new_user.name
        avatar = new_user.avatar
        mail_text = "Unfortunately another user made a higher bid. But you still can make a higher bid."

        content = generateAuctionMailContent(name, avatar, current_host, mail_text)

        subject = "Sorry, you were outbid."
        sendMail(email, content, subject)
      end
    end

    ##
    #
    #  Methods to generate the HTML Mail content for user.
    #
    ##
    def generateMailContent(name, avatar, reg_hash, current_host)
      host = current_host
      img_url = "http://#{host}#{avatar}"
      conf_url = "http://#{host}/registration/confirm/#{reg_hash}"

      content = render_file_for_mail('mail.haml', Array[host, name, img_url, conf_url])
      return content
    end

    def generateAuctionMailContent(name, avatar, current_host, mail_type)
      host = current_host
      img_url = "http://#{host}#{avatar}"

      content = render_file_for_mail('mail_auction.haml', Array[host, name, img_url, mail_type])
      return content
    end

    ##
    #
    # Method to send e-mail with generated content.
    #
    ##
    def sendMail(receiver, content, subject)
      SimpleEmailClient.setup.send_email(receiver, subject, content)
    end

  end

end