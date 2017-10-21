# ThrottleMe

Install
--------

Redis is a required dependency. Make sure you have both redis-server installed and running before use.

Add the following line to Gemfile:

```ruby
gem 'throttle_me', :git => "git://github.com/bkarst/throttle_me.git"
```

and run `bundle install` from your shell.

Usage without Blocks
--------
```ruby
  token = 'api_token'
  window_size = 60 #window size in seconds
  requests_per_window_size = 60 #requests per windo
  res = ThrottleMe.request(@token, window_size: window_size, requests_per_window_size: requests_per_window_size)
  if res == true
    puts "RUN MY CODE"
  end
```

Usage with Blocks
--------
```ruby
  token = 'api_token'
  window_size = 60 #window size in seconds
  requests_per_window_size = 60 #requests per windo
  res = ThrottleMe.request(@token, window_size: window_size, requests_per_window_size: requests_per_window_size) do
    puts "RUN MY CODE"
  end
```
