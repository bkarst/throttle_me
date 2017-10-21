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

ThrottleMe.request will return either the boolean value true or the number of seconds you need to
wait until it is safe to call the API without violating the rate limit.

--------
```ruby
  token = 'api_token'
  window_size = 60 #window size in seconds
  requests_per_window_size = 60 #requests per windo
  res = ThrottleMe.request(@token,
      window_size: window_size,
      requests_per_window_size: requests_per_window_size)
  if res == true
    puts "RUN MY CODE"
  else
    puts res #number of seconds until it is safe to call the API
  end
```

Usage with Blocks
--------
```ruby
  token = 'api_token'
  window_size = 60 #window size in seconds
  requests_per_window_size = 60 #requests per windo
  res = ThrottleMe.request(@token, window_size: window_size,
    requests_per_window_size: requests_per_window_size) do
    puts "RUN MY CODE" #this code will only be run if you are allowed
  end  
```
