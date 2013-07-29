require 'pty'
require 'pathname'
location = "#{File.dirname(__FILE__)}"
number = location.partition('/').last.to_i
current = location.partition('/')
last = current.last.partition('/').last
puts "current: #{current}"
puts "last: #{last}"