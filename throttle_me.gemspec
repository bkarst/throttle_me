Gem::Specification.new do |s|
  s.name        = 'throttle_me'
  s.version     = '0.1.0'
  s.licenses    = ['MIT']
  s.summary     = "Throttle outgoing API requests to adhere to rate limits set by real time APIs."
  s.description = "Real time APIs like Twitter and Reddit limit the amount of requests per credential per time window. Throttle Me is a gem intended to make single or multi process ruby applications sensitive to these rate limits."
  s.authors     = ["Ben Karst"]
  s.email       = 'ben.karst@gmail.com'
  s.files       = ["lib/throttle_me.rb"]
  s.homepage    = 'https://rubygems.org/gems/example'
  s.add_runtime_dependency 'redis-rb', '~> 3.0'
  s.add_development_dependency 'timecop', '~> 1.1', '>= 1.1.4'
end
