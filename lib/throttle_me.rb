#Realtime APIs like Twitter and Reddit allow to you make requests free of charge
#but they impose limitations on how many calls you can make per minute.
#The purpose of the request Throttler is avoid failed calls or
#being banned due to making too many requests per minute.

#If you have a ton of instances of running at the same time,
#looking at the response headers will not be enough and you may violate
#rate limits.
#http://praw.readthedocs.io/en/latest/getting_started/multiple_instances.html

#we are persisting the request count in Redis because we might want to
#distribute requests across multiple processes

#must be tested with different window sizes

#to test this code we will run the request 100 times and see if it stalls on
#the 61st attempt

#throttle me

require 'redis'
require 'json'
require 'time'

class ThrottleMe

  class << self
    attr_accessor :window_size, :requests_per_window_size
  end

  def self.new_counter
    {start_time: Time.now, request_count: 1}
  end

  def self.start_time(token)
    Time.parse(redis.get(token + 'start_time')).to_i
  end

  def self.reset_counter(token)
    redis.set(token, 1)
    redis.set(token + 'start_time', Time.now)
    redis.expire(token, self.window_size)
  end

  def self.redis
    @redis||=Redis.new
  end

  def self.increment_counter(token)
    redis.incr(token)
    # hash = JSON.parse(redis.get(token))
    # hash["request_count"] = hash["request_count"] + 1
    # redis.set(token, hash.to_json)
  end

  #the test could consist of calling request for several different tokens and making sure none are blocking.

  def self.request(token, window_size: 60, requests_per_window_size: 60)
      #window size in seconds
      self.window_size = window_size
      self.requests_per_window_size = requests_per_window_size
      request_count = redis.get(token)
      # request_state = JSON.parse(request_state) if request_state
      #this is our first call
      if request_count.nil?
        reset_counter(token)
        # redis.set(token, new_counter.to_json)
        yield if block_given?
        #if we are less than the request quote, we can continue to make requests
      elsif request_count.to_i < requests_per_window_size
        increment_counter(token)
        yield if block_given?
        #if it's been more than 1 minute since we began tallying requests, we can start again
      # elsif Time.now > (Time.parse(request_state["start_time"]) + window_size)
      #   redis.set(token, new_counter.to_json)
      #   yield if block_given?
      else
        #the caller must wait to execute the block/request
        #we return how many seconds the caller must wait to call with this token
        return start_time(token) + window_size - Time.now.to_i
      end
      #we indicate to the caller that the block/request passed has been executed
      true
    end
  # end

end
