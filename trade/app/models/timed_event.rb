module Models
  class TimedEvent
    attr_accessor :time, :subscribers, :scheduler, :timed_out, :job

    def self.create(object_to_time, time)
      fail "Object to be called should not be nil" if object_to_time.nil?
      fail "Time should not be nil" if time.nil?
      fail "Should have method #timed_out implemented" unless object_to_time.respond_to?(:timed_out)
      fail "Time should not be in past" unless time == :forever || time >= Time.now

      event = TimedEvent.new
      event.scheduler = Rufus::Scheduler.start_new

      event.timed_out = false
      event.subscribers = Array.new
      event.subscribers.push(object_to_time)

      if (time == :forever)
        event.time = :forever
      else
        event.time = time

        time = Rufus.to_datetime time

        event.job = event.scheduler.at time.to_s do
          event.timed_out = true
          event.subscribers.each { |object| object.timed_out }
        end
      end

      event
    end

    def subscribe(object_to_time)
      fail "Should have method #timed_out implemented" unless object_to_time.respond_to?(:timed_out)

      self.subscribers.push(object_to_time)
    end

    def reschedule(time)
      time_rufus = Rufus.to_datetime time

      self.job.unschedule unless (self.time == :forever)

      self.job = self.scheduler.at time_rufus.to_s do
        self.timed_out = true
        self.subscribers.each { |object| object.timed_out }
      end

      self.time = time
    end

    def unschedule
      if (self.time != :forever)
        self.job.unschedule
        self.time = :forever
        self.timed_out = false
      end
    end

    def scheduled?
      self.time != :forever
    end
  end
end