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

      sendMail(email, content)
    end

    def sendWinnerMail(userid, current_host)
      content = 'Gratulation, du hast die Auktion gewonnen'
      email = 'test@gmail.com'
      sendMail(email, content)
    end

    def sendLooserMail(userid, current_host)
      content = 'Sorry, die Auktion wurde von jemand Anderem gewonnen.'
      email = 'test@gmail.com'
      sendMail(email, content)
    end

    ##
    #
    #  Method to generate the HTML Mail content for user.
    #
    ##
    def generateMailContent(name, avatar, reg_hash, current_host)
      host = current_host
      img_url = "http://#{host}#{avatar}"
      conf_url = "http://#{host}/registration/confirm/#{reg_hash}"

      content = render_file_for_mail('mail.haml', Array[host, name, img_url, conf_url])
      return content
    end

    ##
    #
    # Method to send e-mail with generated content.
    #
    ##
    def sendMail(receiver, content)
      subject = "Welcome to the ESE-Tradingsystem!"
      SimpleEmailClient.setup.send_email(receiver, subject, content)
    end



  end

end