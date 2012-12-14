module Models
  ##
  #
  # Creates a timed event that calls timed_out of the
  # given object to time after after a specified time.
  #
  # Usage in our model:
  # Lets an item expire if the specified time is up. If
  # this happens the item is set to inactive.
  #
  # time: when the TimedEvent triggers. :forever if the timed_event is not triggered at all
  # subscribers : all objects that are affected by the TimedEvent
  # timed_out : true if the current job has timed out
  #
  ##

  class TimedEvent
    attr_reader :time, :timed_out

    @subscribers #subscribers of this event
    @scheduler #schedules and reschedules jobs (see Rufus::Scheduler)
    @job #the current job (see Rufus::Scheduler)

    def initialize
      @time = :forever
      @timed_out = false
      @subscribers = Array.new
      @scheduler = Rufus::Scheduler.start_new
    end

    ##
    #
    # The constructor for this class
    #
    ##
    def self.create(object_to_time, time)
      fail "Object to be called should not be nil" if object_to_time.nil?
      fail "Time should not be nil" if time.nil?
      fail "Should have method #timed_out implemented" unless object_to_time.respond_to?(:timed_out)
      fail "Time should not be in past" unless time == :forever || time >= Time.now

      event = TimedEvent.new
      event.subscribe(object_to_time)

      unless (time == :forever)
        event.reschedule(time)
      end

      event
    end

    ##
    #
    # Adds an object to this timed event. If the timed event reaches the
    # specified time this object performs his timed_out method
    #
    # Each object that shall be time must implement a #timed_out
    # method. A TimedEvent can have multiple subscribers.
    #
    ##
    def subscribe(object_to_time)
      fail "Should have method #timed_out implemented" unless object_to_time.respond_to?(:timed_out)

      @subscribers.push(object_to_time)
    end

    ##
    #
    # Reschedules the time when the method #timed_out is called.
    #
    ##
    def reschedule(time)
      time_rufus = Rufus.to_datetime time

      @job.unschedule unless (self.time == :forever)

      @job = @scheduler.at time_rufus.to_s do
        @timed_out = true
        @subscribers.each { |object| object.timed_out }
      end

      @time = time
    end

    ##
    #
    # Removes the specified time,
    # so that the TimedEvent never
    # triggers(unless a new time is
    # set in #reschedule(time))
    #
    ##
    def unschedule
      if (self.time != :forever)
        @job.unschedule
        @time = :forever
        @timed_out = false
      end
    end

    ##
    #
    # Checks if an event is scheduled
    # Returns true if it is. False
    # otherwise.
    #
    ##
    def scheduled?
      @time != :forever
    end

    ##
    #
    # Returns all subscribers of this
    # timed event.
    #
    ##

    def subscribers
      @subscribers.clone
    end
  end
end