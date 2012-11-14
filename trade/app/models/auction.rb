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
      fail "Price can't be negative" if (start_price < 0)
      fail "Increment can't be negative" if (increment < 0)

      time_now = Time.new
      auction = self.new
      auction.id = nil
      auction.item = item
      auction.bidder = Array.new
      auction.bidder.push(nil)
      auction.price = Array.new
      auction.price.push(start_price)
      auction.increment = increment
      auction.start_time = Time.now
      auction.end_time = end_time
      auction.money_storage_hash = Hash.new
      auction
    end

    # to String-method
    def to_s
      "#{self.id}, #{self.item}, #{self.price}"
    end

    # Stores auction in system hashmap
    def store()
      Models::System.instance.add_auction(self)
    end

    def change_starting_price(new_price)
      # if no bids done yet
      if no_bid_done_yet?
        self.price[0] = new_price
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
      exists = false
      self.money_storage_hash.each_key {|user_db|
        if user_db == user
          exists = true
        end
      }
      #add bet to hash
      if self.price[(self.price.length) -1] < max_price
        if exists
          self.money_storage_hash[user] = max_price
        else
          self.money_storage_hash.store(user, max_price)
        end
      end
      #update_auction
      self.update()
    end

    def update()
      #check if storage hash has higher values than current bid
      max = self.money_storage_hash.values.max
      all_bids_except_max = self.money_storage_hash.values.delete(max)
      if max > self.price[(self.price.length) -1]
        #increment until second highest bid overtaked
        while all_bids_except_max >= self.price
          self.price += increment
        end
        #set new bidder (add to array)
        self.money_storage_hash.each_key {|user_db|
          if self.money_storage_hash[user_db] == max
            self.bidder.push(user_db)
          end
        }
      end
      notify_all()
    end

    def finalize_auction
      self.money_storage_hash.each_key {|user_db|
        if user_db == getWinner then
          #give winner the item and max_price - item_price
          self.item.bought_by(user_db)
          user_db.credits += self.money_storage_hash[user_db] - self.price
        else
          #give looser the max_price
          user_db.credits += self.money_storage_hash[user_db]
        end
      }
    end

    def getWinner()
      self.bidder.last
    end

    def notify_all
      if !auction_closed then
        # notify new leader
        Mailer.setup.sendLeaderMail(getWinner.id, "#{request.host}:#{request.port}")
        # notify overbidden people
        self.bidder.select {|bidder|
          if bidder != getWinner then
            Mailer.setup.sendOutbidMail(bidder.id, "#{request.host}:#{request.port}")
          end
        }
      end
    end

    def notify_winner
      if auction_closed then
        Mailer.setup.sendWinnerMail(getWinner.id, "#{request.host}:#{request.port}")
      end
    end

    def notify_looser
      if auction_closed then
        self.money_storage_hash.each_key {|user_db|
          if user_db != getWinner then
            Mailer.setup.sendLooserMail(user_db.id, "#{request.host}:#{request.port}")
          end
        }
      end
    end

    # Removes itself from the list of auctions and of the system
    def clear
      System.instance.remove_auction(self.id)
    end

    # Reports if auction is running or finished
    def auction_closed
      time_now = Time.new
      self.end_time < time_now
    end

    def can_be_bid_by?(user,max_bid)
      user.credits >= max_bid
    end

    def no_bid_done_yet?()
      self.bidder[(self.bidder.length) -1]==nil
    end

    def bid_exists?(bid)
      #bid = bid.to_i
      #unique_bid_quotas = []
      #self.money_storage_hash.each { |user|
      #   unique_bid_quotas.push((self.money_storage_hash[user]/self.increment).to_i) unless self.money_storage_hash[user]==nil
      #}
      #unique_bid_quotas.include?((bid/self.increment).to_i)
      false
    end

    def time_till_end
      time_till_end = (Time.parse(self.end_time) - Time.now)

      if time_till_end > 0
        time_till_end
      else
        "Auction is over"
      end
    end

  end
end