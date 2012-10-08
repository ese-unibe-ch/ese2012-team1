require 'test/unit'
require 'rubygems'
require 'require_relative'
require 'test_description_simplifier'

require_relative('../app/helpers/string_checkers')

class StringCheckerTest < Test::Unit::TestCase
  should "accept mail@mail.ch as e-mail" do
    string = "mail@mail.ch"
    assert(string.is_email?)
  end

  should "accept mail.mail@mail.ch as e-mail" do
    string = "mail.mail@mail.ch"
    assert(string.is_email?)
  end

  should "accept mail_mail@mail.ch as e-mail" do
    string = "mail_mail@mail.ch"
    assert(string.is_email?)
  end

  should "accept numbers before @ as e-mail" do
    string = "1234567890@mail.ch"
    assert(string.is_email?)
  end

  should "accept mail@mail.mail.ch" do
    string = "mail@mail.mail.ch"
    assert(string.is_email?)
  end

  shouldnt "accept mail@mail. as e-mail" do
    string = "mail@mail."
    assert(!string.is_email?)
  end

  shouldnt "accept mailmail.ch as e-mail" do
    string = "mailmail.ch"
    assert(!string.is_email?)
  end

  should "accept password with digits, capital letters and small letters" do
    string = "123ABCabc"
    assert(string.is_strong_password?)
  end

  shouldnt "accept short password" do
    string = "1aA"
    assert(!string.is_strong_password?)
  end

  shouldnt "accept password with only capital and small letters" do
    string = "abcdABCD"
    assert(!string.is_strong_password?)
  end

  shouldnt "accept password with only small letters and digits" do
    string = "abcd1234"
    assert(!string.is_strong_password?)
  end

  shouldnt "accept password with only captial letters and digits" do
    string = "ABCD1234"
    assert(!string.is_strong_password?)
  end
end