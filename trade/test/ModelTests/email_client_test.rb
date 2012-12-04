require 'test_require'
require 'test/unit'
require 'rubygems'
require '../../app/models/simple_email_client'

class Email_client_test < Test::Unit::TestCase

  def setup
    @client = SimpleEmailClient.setup
  end

  def test_no_receiver
    assert_raise(ArgumentError,"Missing receiver") {@client.send_email("Hello","I'm a test.")}
  end

  def test_no_content
    assert_raise(ArgumentError,"Missing content") {@client.send_email("peter@mail.ch","Hello")}
  end

  def test_email_not_correct
    assert_raise(RuntimeError,"Not a correct email address") {@client.send_email("peter@mail","Hello", "I' m testing.")}
  end

  def test_empty_string_subject
    assert_nothing_raised(ArgumentError) {@client.send_email("peter@mail.ch","","How are you?")}
  end

  def test_no_subject
    assert_nothing_raised {@client.send_email("peter@mail.ch",nil,"Hi.")}
  end
end