require 'test_require'
require 'test/unit'

class Net::SMTP
  @@start = false

  def self.start(*args)
    @@start = true
  end

  def self.enable_tls(*args)
  end

  def self.started?
    started = @@start
    @@start = false
    return started
  end
end

class Email_client_test < Test::Unit::TestCase

  def setup
    @client = SimpleEmailClient.setup
  end

  def test_no_receiver
    assert_raise(RuntimeError,"Missing receiver") { @client.send_email(nil, "Hello","I'm a test.") }
  end

  def test_no_content
    assert_raise(RuntimeError,"Missing content") { @client.send_email("peter@mail.ch", "Hello", nil) }
  end

  def test_email_not_correct
    assert_raise(RuntimeError,"Not a correct email address") {@client.send_email("peter@mail","Hello", "I' m testing.")}
  end

  def test_empty_string_subject
    @client.send_email("peter@mail.ch","","How are you?");
    assert(Net::SMTP.started?, "Should have send mail")
  end

  def test_no_subject
    @client.send_email("peter@mail.ch",nil,"Hi.")
    assert(Net::SMTP.started?, "Should have send mail")
  end
end