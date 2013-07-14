def hello
	puts "Hello from: #{File.dirname(__FILE__)}\n"
end
hello

location = "#{File.dirname(__FILE__)}"
local_fname = "#{location}/n.txt"
unless File.exists?(local_fname)
	runs = 1
	File.open(local_fname, 'w') do |f| 
		f.write(runs.to_s)
	end
    puts "\t...Success, saved to #{local_fname}"
else
	s = File.open(local_fname, 'r') { |f| f.read }
	runs = s.to_i + 1
	File.open(local_fname, 'w') do |f|
		f.write(runs)
	end
	puts "\t #{runs} times"
end


#require 'rubygems'
#require 'mechanize'

#BASE_URL = 'http://en.wikipedia.org/wiki/'
#BASE_DIR = ''
#contents = ''
#begin
#	agent = Mechanize.new
#	page = agent.get(BASE_URL+BASE_DIR+contents)
#ensure
#	sleep 1.0 + rand
#end #begin