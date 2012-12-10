require "test_require"

describe Message do
  def create_message(args = {})
    sender = args.member?(:sender) ? args[:sender] : "1"
    subject = args.member?(:subject) ? args[:subject] : "Subject"
    @date = args.member?(:date) ? args[:date] : Time.now
    message = args.member?(:message) ? args[:message] : "My Message"
    receiver = args.member?(:receiver) ? args[:receiver] : "2"
    reply_to = args.member?(:reply_to) ? args[:reply_to] : nil

    Message.create(sender, receiver, subject, @date, message, reply_to)
  end

  context "when creating" do
    it "should fail if no receiver is set" do
      lambda{ create_message(:receiver => nil)}.should raise_error(RuntimeError)
    end

    it "should fail if no sender is set" do
      lambda{ create_message(:sender => nil)}.should raise_error(RuntimeError)
    end

    it "should fail if no date is set" do
      lambda{ create_message(:date => nil)}.should raise_error(RuntimeError)
    end

    it "should fail if no message is set" do
      lambda{ create_message(:message => nil) }.should raise_error(RuntimeError)
    end

    it "should fail if message is an empty string" do
      lambda{ create_message(:message => "") }.should raise_error(RuntimeError)
    end

    it "should fail if reply to is a string" do
      lambda{ create_message(:reply_to => "nr 1") }.should raise_error(RuntimeError)
    end
  end

  context "when created" do
    it "should hold given message" do
      message = create_message
      message.message.should be_like "My Message"
    end

    it "should hold given subject" do
      message = create_message
      message.subject.should be_like "Subject"
    end

    it "should hold given date" do
      message = create_message
      message.date.should be_like @date
    end

    context "with reply_to nil" do
      it "should hold given reply_to" do
        message = create_message
        message.reply_to.should be_nil
      end
    end

    context "with reply_to an integer" do
      it "should hold given reply_to" do
        message = create_message(:reply_to => 2)
        message.reply_to.should be_like 2
      end
    end
  end
end