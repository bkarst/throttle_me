require 'redis'
require 'json'
require 'time'

class ThrottleMe

  class << self
    attr_accessor :window_size, :requests_per_window_size
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

  def self.request(token, window_size: 60, requests_per_window_size: 60)
      self.window_size = window_size
      self.requests_per_window_size = requests_per_window_size
      request_count = redis.get(token)
      if request_count.nil?
        reset_counter(token)
        yield if block_given?
      elsif request_count.to_i < requests_per_window_size
      #if we are less than the request quota, we can continue to make requests
        redis.incr(token)
        yield if block_given?
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
