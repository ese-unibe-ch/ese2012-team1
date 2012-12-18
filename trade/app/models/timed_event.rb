module Models
  ##
  #
  # Creates a timed event that calls timed_out of the
  # given object to time after after a specified time.
  #
  #
  # === Usage in model
  #
  # Lets an item expire if the specified time is up. If
  # this happens the item is set to inactive.
  #
  ##

  class TimedEvent
    # Time when the TimedEvent triggers. :forever if the timed_event is not triggered at all
    attr_reader :time
    # +timed_out+;: true if the last job has timed out
    attr_reader :timed_out

    @subscribers #all objects that are affected by the TimedEvent
    @scheduler #schedules and reschedules jobs (see Rufus::Scheduler)
    @job #the current job (see Rufus::Scheduler)

    ##
    #
    # Initially +time+ is set to :forever and +timed_out+ to false.
    # There are no subscribers at the beginning.
    #
    ##

    def initialize
      @time = :forever
      @timed_out = false
      @subscribers = Array.new
      @scheduler = Rufus::Scheduler.start_new
    end

    ##
    #
    # The factory method (constructor) for this class
    #
    # +object_to_time+:: Object to be called when TimedEvent expires (can't be nil and must respond to #timed_out)
    # +time+:: time when the call to #timed_out of +object_to_time+ happens. Values for +time+ are either a Time
    #          or the flag :forever (can't be nil and can't be in past)
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
    # specified +time+ this object performs his timed_out method
    #
    # Each object that shall be time must implement a #timed_out
    # method. A TimedEvent can have multiple subscribers.
    #
    # +object_to_time+:: object to be timed by this TimedEvent
    #
    ##
    def subscribe(object_to_time)
      fail "Should have method #timed_out implemented" unless object_to_time.respond_to?(:timed_out)

      @subscribers.push(object_to_time)
    end

    ##
    #
    # Reschedules the time when the method #timed_out is called
    # on all subscribers
    #.
    # To set the time to :forever use #unschedule
    #
    # +time+:: New time to be scheduled. Can be Time (Can't be nil)
    #
    ##
    def reschedule(time)
      "missing time" if time.nil?

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
    # Sets +time+ to :forever and
    # +timed_out+ to false
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
    # Returns an array of all subscribers of this
    # timed event. Changes on this array don't
    # affect the TimedEvent
    #
    ##

    def subscribers
      @subscribers.clone
    end
  end
end