$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "minitest/autorun"
require 'throttle_me'
require 'redis'

describe ThrottleMe do

  def expire_tokens
    [@token, @token2].each do |token|
      @redis.expire(token, -1)
      @redis.expire(token + "start_time", -1)
    end
  end

  before do
    @redis = Redis.new
    @token = 'testtoken'
    @token2 = 'testtoken2'
  end

  after do
    expire_tokens
  end

  describe "when asked about cheeseburgers" do
    it "must respond positively" do
      requests_per_window_size, window_size = 60, 60
      #call the maximum amount of times per window
      requests_per_window_size.times do |x|
        res = ThrottleMe.request(@token, window_size: window_size, requests_per_window_size: requests_per_window_size)
        assert_equal res, true
      end
      #call one more than the maximum, should return a number
      res = ThrottleMe.request(@token, window_size: window_size, requests_per_window_size: requests_per_window_size)
      assert res != true
    end

    it "responds positively after waiting" do
      requests_per_window_size, window_size = 60, 2
      #call the maximum amount of times per window
      requests_per_window_size.times do |x|
        res = ThrottleMe.request(@token, window_size: window_size, requests_per_window_size: requests_per_window_size)
        assert_equal res, true
      end
      #call one more than the maximum, should return a number
      res = ThrottleMe.request(@token, window_size: window_size, requests_per_window_size: requests_per_window_size)
      assert res != true
      # since we use redis key expiration to manage our time
      # windows, we cannot use Timecop
      # this makes the code more elegant but the testing less so
      sleep(window_size + 1)
      res = ThrottleMe.request(@token, window_size: window_size, requests_per_window_size: requests_per_window_size)
      assert_equal res, true
    end

    it "works with multiple tokens" do
      requests_per_window_size, window_size = 60, 2
      #call the maximum amount of times per window
      requests_per_window_size.times do |x|
        res = ThrottleMe.request(@token, window_size: window_size, requests_per_window_size: requests_per_window_size)
        assert_equal res, true
      end
      requests_per_window_size.times do |x|
        res = ThrottleMe.request(@token2, window_size: window_size, requests_per_window_size: requests_per_window_size)
        assert_equal res, true
      end
    end

    it "executes code within blocks only when under the request limit" do
      requests_per_window_size, window_size = 60, 2
      #call the maximum amount of times per window
      counter = 0
      requests_per_window_size.times do |x|
        res = ThrottleMe.request(@token, window_size: window_size, requests_per_window_size: requests_per_window_size) do
          counter = counter + 1
        end
        assert_equal res, true
      end
      assert_equal counter, requests_per_window_size
      #this block should not be executed
      res = ThrottleMe.request(@token, window_size: window_size, requests_per_window_size: requests_per_window_size) do
        counter = counter + 1
      end
      assert_equal counter, requests_per_window_size
    end


  end


end
