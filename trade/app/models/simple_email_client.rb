require 'parseconfig'
require 'tlsmail'
require 'time'

##
#
# Sending E-mail via ruby
#
# Example of usage:
#
# <tt>require 'rubygems'
# require 'require_relative'
# require 'simple_email_client'
#
# client = SimpleEmailClient.setup
#
# content = <<HERE
# Hello John!
# HERE
#
# client.send_email("youremail@mail.ch", "Send E-Mails with Ruby", content)</tt>
#
# This class is base on code from: http://rolandtanglao.com/archives/2010/07/29
# /ruby-code-send-email-using-gmail
#
#
##

class SimpleEmailClient
  @password
  @from

  ##
  #
  # Load data with ParseConfig and set password
  # and sender. Data is loaded from '../private
  # /email.conf'. Its content should be
  #
  # from_address = 'yourEmail@address'
  # p = 'yourPassword'
  #
  ##

  def self.setup
    return self.new()
  end

  def initialize()
    path = absolute_path('../private/email.conf', __FILE__)
    email_config = ParseConfig.new(path).params

    @from = email_config['from_address']
    @password = email_config['p']
  end

  ##
  #
  # Sending email from tradingsystemese@gmail.com
  #
  # @param to : Receiver of the e-mail
  # @param subject : e-mail header
  # @param content : text to be send
  #
  ##

  def send_email(to, subject, content)
    fail "Missing receiver" if to.nil?
    fail "Missing content" if content.nil?
    fail "Not a correct email address" unless to.is_email?

    subject = subject.nil? ? "" : subject

#E-Mailsetup with a here document
content_file = <<-EOF
From: #@from
To: #{to}
subject: #{subject}
Date: #{Time.now.rfc2822}
MIME-Version: 1.0
Content-type: text/html;charset=UTF-8;

#{content}
EOF

    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)

    #Sending message via smtp server of gmail
    Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', @from, @password, :login) do |smtp|
      smtp.send_message(content_file, @from, to)
    end
  end
end



