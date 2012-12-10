require "test_require"

describe Conversation do
  before(:each) do
    @conversation = Conversation.new
  end

  it "should have a conversation id" do
    @conversation.conversation_id.should_not be_nil

    conversation2 = Conversation.new

    conversation2.conversation_id.should == @conversation.conversation_id + 1
  end

  context "when created" do
    before(:each) do
      @system = double("System")
      System.stub(:instance).and_return(@system)
      @system.stub(:account_exists?).and_return(true)

      @subscribers = [double("Subscriber 1"), double("Subscriber 2")]
      @conversation = Conversation.create(@subscribers)
    end

    it "should have added subscribers as subscribers" do
      @conversation.subscribers.should == @subscribers
    end

    context "when adding a message" do
      before(:each) do
        @message1 = double("Message 1")
        @message1.stub(:message_id).and_return(1)
        @message1.stub(:reply_to).and_return(nil)
        @message1.stub(:depth).and_return(0)

        @conversation.add_message(@message1)
      end

      it "should add message" do
        @conversation.messages.size.should == 1
      end

      it "should get message" do
        @conversation.get(1).should == @message1
      end
    end

    context "when adding a reply to a message" do
      before(:each) do
        @message1 = double("Message 1")
        @message1.stub(:message_id).and_return(1)
        @message1.stub(:reply_to).and_return(nil)
        @message1.stub(:depth).and_return(0)

        @message2 = double("Message 2")
        @message2.stub(:message_id).and_return(2)
        @message2.stub(:reply_to).and_return(nil)
        @message2.stub(:depth).and_return(0)

        @reply_to_message1 = double("Reply to message 1")
        @reply_to_message1.stub(:message_id).and_return(3)
        @reply_to_message1.stub(:reply_to).and_return(1)
        @reply_to_message1.stub(:depth).and_return(0)
        @reply_to_message1.stub(:depth=)
      end

      def add_messages
        @conversation.add_message(@message1)
        @conversation.add_message(@message2)
        @conversation.add_message(@reply_to_message1)
      end

      it "should add reply right behind the message it was replying to" do
        add_messages

        @conversation.messages.size.should == 3

        @conversation.messages.fetch(0).should == @message1
        @conversation.messages.fetch(1).should == @reply_to_message1
        @conversation.messages.fetch(2).should == @message2
      end

      it "should set message depth to one deeper than message it replies to" do
        @reply_to_message1.should_receive(:depth=).with(1)

        add_messages
      end
    end
  end

  it "should be observable" do
    observer = double("Observer")
    observer.stub(:update)

    @conversation.add_observer(observer)

    @conversation.count_observers.should == 1
  end

  context "when observed" do
    before(:each) do
      @message = double("Message")
      @message.stub(:message_id).and_return(1)
      @message.stub(:reply_to).and_return(nil)
    end

    it "should be updated when new message arrives" do
      observer = double("Observer")
      observer.stub(:update)

      @conversation.add_observer(observer)

      observer.should_receive(:update).with(@conversation, @message)

      @conversation.add_message(@message)
    end
  end
end