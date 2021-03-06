require "test_require"

describe MessageBox do
  context "when created" do
    before(:each) do
      @message_box = MessageBox.create(1)
    end

    it "should hold zero conversations" do
      @message_box.conversations.size.should == 0
    end

    it "should holds user id as owner" do
      @message_box.owner.should == 1
    end

    it "should hold no messages in message tree" do
      @message_box.message_tree.size.should == 0
    end

    it "should have no messages" do
      @message_box.messages_count.should == 0
    end

    it "should have no new messages" do
      @message_box.new_messages?.should be_false
    end

    it "should have zero new messages" do
      @message_box.new_messages_count.should == 0
    end

    it "should not travers any message" do
      @message_box.travers_new_messages do |message|
        true.should be_false
      end

      true.should be_true
    end

    context "when a conversation is added" do
      before(:each) do
        @conversation = double("Conversation")
        @conversation.stub(:conversation_id).and_return(5)
        @conversation.stub(:messages).and_return(Array.new)
        @conversation.stub(:add_observer)
        @message_box.add_conversation(@conversation)
      end

      it "should hold one conversation" do
        @message_box.conversations.size.should == 1
      end

      context "when updated is called because a new message of user2 is added" do
        before(:each) do
          @message = double("Message")
          @message.should_receive(:is_receiver?).with(1).and_return(true)
          @message.should_receive(:sender).and_return(2)
          @message.should_receive(:message_id).and_return(1)
          @message_box.update(@conversation, @message)
          @conversation.stub(:get).with("1").and_return(@message)
        end

        it "should have one messages" do
          @message_box.messages_count.should == 1
        end

        it "should have new messages" do
          @message_box.new_messages?.should be_true
        end

        it "should have one new messages" do
          @message_box.new_messages_count.should == 1
        end

        it "should have one new message for this conversation" do
          @message_box.new_messages_count_for(@conversation.conversation_id).should == 1
        end

        it "message should not be read" do
          @message_box.read?(5,1).should be_false
        end

        it "should travers over one message" do
          @message.should_receive(:is_receiver?).with(1).and_return(true)

          @message_box.travers_new_messages do |message, conversation_id|
            message.should == @message
          end
        end

        context "when new message is set as read" do
          before(:each) do
            @message_box.set_as_read(5, 1)
          end

          it "should have no new messages" do
            @message_box.new_messages?.should be_false
          end

          it "should have zero new messages" do
            @message_box.new_messages_count.should == 0
          end

          it "message should be read" do
            @message_box.read?(5,1).should be_true
          end
        end
      end
    end
  end
end