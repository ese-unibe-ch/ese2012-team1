
module CustomMatchers
  class BeLike
    def initialize(comperer)
      @comperer = comperer
    end

    def matches?(to_match)
      @to_match = to_match
      to_match == @comperer
    end

    def failure_message_for_should
      "expected to be like \'#{@comperer}\' but was \'#{@to_match}\'"
    end
  end

  def be_like(expression)
    BeLike.new(expression)
  end

  class RespondTo
    def initialize(symbol)
      @symbol = symbol
    end

    def matches?(to_match)
      to_match.respond_to?(@symbol)
    end

    def failure_message_for_should
      "expected to respond to @symbol"
    end
  end

  def respond_to(symbol)
    RespondTo.new(symbol)
  end
end