require 'rubygems'
require 'require_relative'

require_relative '../helpers/render'
require_relative 'system'
require_relative 'comment_container'

include Helpers

module Models
  class Auction


    # generate getter and setter for name and price
    attr_accessor :id, :item, :price, :bidder, :increment, :start_time, :end_time, :money_storage_hash




    # factory method (constructor) on the class
    def self.created(item, start_price, increment, end_time)
      #Preconditions
      fail "Auction needs an item." if (item == nil)
      fail "Auction needs a start price." if (start_price == nil)
      fail "Auction needs a time limit." if (end_time == nil)
      fail "Auction needs a valid time limit." if (end_time <= time_now)
      fail "Price can't be negative" if (start_price < 0)
      fail "Increment can't be negative" if (increment < 0)

      time_now = Time.new
      auction = self.new
      auction.id = nil
      auction.item = item
      auction.bidder = nil
      auction.price = start_price
      auction.increment = increment
      auction.start_time = time_now
      auction.end_time = end_time
      auction.money_storage_hash = Hash.new
      auction
    end

    # to String-method
    def to_s

    end

    # Stores auction in system hashmap
    def store()
      Models::System.instance.add_auction(self)
    end

    def change_starting_price(new_price)
      # if no bids done yet
      if no_bid_done_yet?
        self.price = new_price
      end
    end

    def change_end_time(new_end_time)
      # if no bids done yet
      if no_bid_done_yet?
        self.end_time = new_end_time
      end
    end

    def change_increment(new_increment)
      # if no bids done yet
      if no_bid_done_yet?
        self.increment = new_increment
      end

    end

    def make_bet(user, max_price)
      #check if user already exists in money storage hash

      #add bet to hash
      self.money_storage_hash.push(user, max_price)
      #update_auction
      self.update()
    end

    def update()
      #check if storage hash has higher values than current bid

    end

    def finalize_auction
      #give loosers their money back from money storage
      #give winner the item and max_price - item_price
    end

    def notify_all
      # notify new leader
      # notify overbidden people
    end

    def notify_winner
      #after auction
    end

    def notify_looser
      #after auction
    end

    # Removes itself from the list of auctions and of the system
    def clear
      System.instance.remove_auction(self.id)
    end

    def can_be_bid_by?(user,max_bid)
      user.credits >= max_bid
    end

    def no_bid_done_yet?()
      self.bidder==nil
    end

  end

end