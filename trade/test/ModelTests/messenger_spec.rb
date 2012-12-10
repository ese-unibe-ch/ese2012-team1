require "test_require"

describe Messenger do
  before(:each) do
    #Before
  end

  context "when created" do
    before(:each) do
      @system = double("System")
      System.stub(:instance).and_return(@system)
      @system.stub(:account_exists?).and_return(true)

      @messenger = Messenger.instance
    end

    it "should register user" do
      @messenger.register(1)
      @messenger.message_boxes.member?(1.to_s).should be_true
    end

    it "should register multiple users" do
      @messenger.register(1)
      @messenger.register(2)
      @messenger.register(3)

      @messenger.get_message_box(1).owner.should ==  1
      @messenger.get_message_box(2).owner.should ==  2
      @messenger.get_message_box(3).owner.should ==  3
    end

    context "when two users are registered" do
      before(:each) do
        @messenger.register(1)
        @messenger.register(2)
      end

      context "when a message is send from user1 to user2" do
        before(:each) do
          puts "Here!"
          @messenger.new_message(1, [2], "Subject", "My Message")

          @message_box1 = @messenger.get_message_box(1)
          @message_box2 = @messenger.get_message_box(2)
        end

        it "then user2 should have new messages"  do
          #It's odd that the sender as well has a new message even though he did send it
          @message_box1.new_messages_count.should == 0
          @message_box2.new_messages_count.should == 1

          @message_box2.travers_new_messages do |message, conversation_id|
            puts "Conversation id: #{conversation_id}"
            message.subject.should be_like "Subject"
            message.message.should be_like "My Message"
          end
        end

        it "then user1 and user2 two should have correct message" do
          @message_box1.travers_new_messages do |message, conversation_id|
            puts "Conversation id: #{conversation_id}"
            message.subject.should be_like "Subject"
            message.message.should be_like "My Message"
          end
        end

        after(:each) do
          Messenger.instance.reset
        end
      end

      context "when a new message is send from user1 to user2" do
        before(:each) do
          @messenger.new_message(1, [2], "Subject", "My Message")
        end

        it "then he should answer to this message" do
          @messenger.get_message_box(2).travers_new_messages do |message, conversation_id|
            @messenger.answer_message(2, [1], "Re: Subject", "My return message", conversation_id, message.message_id)
          end
        end
      end
    end

    context "when three users are registered" do
      before(:each) do
        @messenger.register(1)
        @messenger.register(2)
        @messenger.register(3)
      end

      it "should send new message from user2 to user3 and user1" do
        @messenger.new_message(2, [1, 3], "Subject", "My Message")

        @messenger.get_message_box(1).new_messages_count.should == 1
        @messenger.get_message_box(2).new_messages_count.should == 0
        @messenger.get_message_box(3).new_messages_count.should == 1
      end
    end
  end
end