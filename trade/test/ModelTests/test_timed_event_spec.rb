require "test_require"

describe TimedEvent do
  before(:each) do
    @timed = double('timed object')
    @timed.stub(:timed_out)
  end

  def create_timed_event(args = {})
    @start_time = Time.now
    @time = @start_time + (args[:time] || 0.5)
    @event = TimedEvent.create(@timed, @time)
  end

  context "while creation" do
    it "should fail if object to time is nil" do
      lambda{ TimedEvent.create(nil, Time.now + 1)}.should raise_error(RuntimeError)
    end

    it "should fail if time is nil" do
      lambda{ TimedEvent.create(@timed, nil) }.should raise_error(RuntimeError)
    end

    it "should fail if time is in past" do
      lambda{ TimedEvent.create(@timed, Time.now - 1)}.should raise_error(RuntimeError)
    end

    it "should fail if object does not implement method #timed_out" do
      @timed.should_receive(:respond_to?).with(:timed_out).and_return(false)
      lambda{ TimedEvent.create(@timed, Time.now + 1)}.should raise_error(RuntimeError)
    end
  end

  context "when created" do
    context "and time set" do
      #Make sure that there is no job running anymore
      #So that tests don't interfere with each other
      after(:each) do
        @event.job.unschedule
      end

      it "should not be running forever" do
        create_timed_event(:time => 10)

        @event.time.should_not == :forever
      end

      it "should be scheduled" do
        create_timed_event(:time => 10)

        @event.should be_scheduled
      end

      it "should not be timed out" do
        create_timed_event(:time => 10)

        @event.timed_out.should be_false
      end

      it "should have time set" do
        create_timed_event

        @event.time.should be_like @time
      end

      it "should call #timed_out of set object" do
        create_timed_event

        @timed.should_receive(:timed_out)
        sleep(0.8)
      end

      it "should call #timed_out on all subscribed objects" do
        create_timed_event

        timed2 = double('second timed object')
        timed2.stub(:timed_out)
        @event.subscribe(timed2)

        @timed.should_receive(:timed_out)
        timed2.should_receive(:timed_out)
        sleep(1.5)
      end

      context "when reschedule" do
        it "should schedule event later to the time set" do
          create_timed_event(:time => 0.2)

          @event.reschedule(@start_time+0.4)
          @time = @start_time + 0.4

          time = 0
          @timed.should_receive(:timed_out) do
            time = Time.now
          end

          #Should called timed_out after 0.6 seconds
          sleep(0.6)

          @time.should be_within(0.1).of(time)
        end
      end

      context "when unschedule" do
        #Creates a TimedEvent for 1 second and directly
        #unschedule it
        before(:each) do
          create_timed_event(:time => 1)

          @event.unschedule
        end

        it "should run forever" do
          @event.time.should == :forever
        end

        it "should not be timed out" do
          @event.timed_out.should be_false
        end

        it "should not be scheduled anymore" do
          @event.scheduled?.should be_false
        end
      end
    end

    context "with flag :forever" do
      before(:each) do
        @event = TimedEvent.create(@timed, :forever)
      end

      it "should not be scheduled" do
        @event.should_not be_scheduled
      end

      it "should not be timed out" do
        @event.timed_out.should be_false
      end

      it "should run forever" do
        @event.time.should == :forever
      end

      context "when unschedule" do
        before(:each) do
          @event.unschedule
        end

        it "should not change anything" do
          @event.should_not be_scheduled
          @event.timed_out.should be_false
          @event.time.should == :forever
        end
      end

      context "when reschedule" do
        before(:each) do
          @time = Time.now + 0.5
          @event.reschedule(@time)
        end

        after(:each) do
          @event.job.unschedule
        end

        it "should not be running forever" do
          @event.time.should_not == :forever
        end

        it "should be scheduled" do
          @event.should be_scheduled
        end

        it "should not be timed out" do
          @event.timed_out.should be_false
        end

        it "should have time set" do
          @event.time.should be_like @time
        end

        it "should call #timed_out of set object" do
          @timed.should_receive(:timed_out)
          sleep(0.8)
        end
      end
    end
  end
end