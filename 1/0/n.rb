require 'pty'
require 'pathname'
location = "#{File.dirname(__FILE__)}"
number = location.partition('/').last.to_i
next_num = number + 1
current = location.partition('/').last.partition('/').last.to_i
parent = File.expand_path("..",File.dirname(__FILE__))
home_dir = Dir.pwd
local_fname = "#{location}/n.txt"

#check/make parent RAM
if File.exists?("#{parent}/ram.txt")
	previous = File.open("#{parent}/ram.txt", 'r') { |f| f.read }
	concat = current.to_s + previous.to_s
	#if there was previous entry in RAM, check/make new sequence
	if !Dir.exists?("#{home_dir}/#{next_num.to_s}/#{concat}")
		Dir.mkdir("#{home_dir}/#{next_num.to_s}")
		Dir.mkdir("#{home_dir}/#{next_num.to_s}/#{concat}")
		s = File.open("#{location}/n.rb", 'r') { |f| f.read }
		File.open("#{home_dir}/#{next_num.to_s}/#{concat}/n.rb", 'w') { |f| f.write(s) }
		# make backward & forward links from here to location & previous, update RAM
		if File.exists?("#{location}/>.txt")
			forward = File.readlines("#{location}/>.txt") 
			File.open("#{location}/>.txt", 'w+') { |f| f.write("#{home_dir}/#{next_num.to_s}/#{concat}\n") } unless forward.include?(concat)
		end
		File.open("#{home_dir}/#{next_num.to_s}/#{concat}/<.txt", 'w+') { |f| f.write("#{home_dir}/#{number.to_s}/#{previous}") }
		File.open("#{home_dir}/#{next_num.to_s}/#{concat}/<.txt", 'w+') { |f| f.write("#{home_dir}/#{number.to_s}/#{current}") }
		File.open("#{parent}/ram.txt", 'w') { |f| f.write("#{current}.to_s") }
		Dir.glob("#{home_dir}/#{next_num.to_s}/#{concat}/n.rb") do |p| #can I kill this safely?
			begin
			  PTY.spawn( "ruby #{p}" ) do |stdout, stdin, pid|
			    begin
			    	stdout.each { |line| puts line }
			    rescue Errno::EIO
			    end
			  end
			rescue PTY::ChildExited
			  puts "The child process exited!"
			end
		end
	else #this sequence already exists so just go there, fire it, & update
		File.open("#{parent}/ram.txt", 'w') { |f| f.write("#{current}.to_s") }
		Dir.glob("#{home_dir}/#{next_num.to_s}/#{concat}/n.rb") do |p| #can I kill this safely?
			begin
			  PTY.spawn( "ruby #{p}" ) do |stdout, stdin, pid|
			    begin
			    	stdout.each { |line| puts line }
			    rescue Errno::EIO
			    end
			  end
			rescue PTY::ChildExited
			  puts "The child process exited!"
			end
		end
	end
else
	File.open("#{parent}/ram.txt", 'w') { |f| f.write("#{location}".to_s) }
	#read next input? predictions?
	Dir.glob("#{home_dir}/c.rb") do |p|
		begin
		  PTY.spawn( "ruby #{p} #{location}" ) do |stdout, stdin, pid| #arguments?
		    begin
		    	stdout.each { |line| puts line }
		    rescue Errno::EIO
		    end
		  end
		rescue PTY::ChildExited
		  puts "The child process exited!"
		end
	end
end

#bottom-up prediction (put this above in the else statement?)
forward_connections = []
File.open("#{location}/>.txt", 'r').each_line { |line| forward_connections << line}
forward_connections.each do |connection| 
	Dir.glob("#{connection}/n.rb") do |p|
		begin
		  PTY.spawn( "ruby #{p} f" ) do |stdout, stdin, pid| #arguments?
		    begin
		    	stdout.each { |line| puts line }
		    rescue Errno::EIO
		    end
		  end
		rescue PTY::ChildExited
		  puts "The child process exited!"
		end
	end
end

#top-down prediction (put this where? else statement?)
backward_connections = []
File.open("#{location}/<.txt", 'r').each_line { |line| forward_connections << line}
backward_connections.each do |connection|
	Dir.glob("#{connection}/n.rb") do |p|
		begin
		  PTY.spawn( "ruby #{p} b" ) do |stdout, stdin, pid| #arguments?
		    begin
		    	stdout.each { |line| puts line }
		    rescue Errno::EIO
		    end
		  end
		rescue PTY::ChildExited
		  puts "The child process exited!"
		end
	end
end
# if a neuron fires and WAS NOT being predicted, that is an event worthy of attention (re-scan input to learn sequence?)
# if a neuron fires and WAS being predicted, that sequence needs to be strengthened in memory
# MAKE all future predictions ( -- sub-conscious-thought -- ) but don't take any ACTION until the # of predictions has been narrowed
# ----- when predictions are narrowed, TAKE ACTION (in this case, scan ahead/self-input?/ the prediction)
# There is a difference between sequential predictions and merely RELATED patterns
# ------ *thought* -- *cliff notes* -- "ram" somewhere? -- 
#backward = File.readlines("#{home_dir}/#{next_num.to_s}/#{concat}/<.txt") if File.exists?("#{home_dir}/#{next_num.to_s}/#{concat}/<.txt")
