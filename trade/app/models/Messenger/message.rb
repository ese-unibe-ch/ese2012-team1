class Message
  @@message_count = 1

  attr_reader :message_id

  attr_accessor :message, :date, :subject, :reply_to

  def initialize
    @message_id = @@message_count
    @@message_count += 1
  end

  def self.create(subject, date, message, reply_to)
    fail "date should be set" if date.nil?
    fail "message should be set" if message.nil? || message.size == 0
    fail "reply_to must either be nil or positive integer" unless reply_to.nil? || reply_to.to_s.is_positive_integer?

    mes = Message.new

    mes.subject = subject.nil? ? "" : subject
    mes.date = date
    mes.message = message
    mes.reply_to = reply_to

    mes
  end
end