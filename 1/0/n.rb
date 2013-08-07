require 'pty'
require 'pathname'
location = "#{File.dirname(__FILE__)}"
number = location.partition('/').last.to_i
next_num = number + 1
current = location.partition('/').last.partition('/').last.to_i
parent = File.expand_path("..",File.dirname(__FILE__))
home_dir = Dir.pwd
local_fname = "#{location}/n.txt"

forward_connections = []
File.open("#{location}/>.txt", 'r').each_line { |line| forward_connections << line}
backward_connections = []
File.open("#{location}/<.txt", 'r').each_line { |line| backward_connections << line}
global_ram = File.open("#{home_dir}/ram.txt", 'r') { |f| f.read }

#if this neuron is being 100% predicted, but this neuron also only has one possible outcome, keep going
if ARGV[0] == "predict_up" && forward_connections.size < 2 && forward_connections.first.size > 0
	Dir.glob("#{home_dir}/#{forward_connections.first}") do |p|
		begin
		  PTY.spawn( "ruby #{p} predict_up" ) do |stdout, stdin, pid| #arguments?
		    begin
		    	stdout.each { |line| puts line }
		    rescue Errno::EIO
		    end
		  end
		rescue PTY::ChildExited
		  puts "The child process exited!"
		end
	end
#no predictions?
elsif ARGV[0] == "predict_up" && forward_connections.size <= 1 && forward_connections.first.size < 1
	Dir.glob("#{home_dir}/c.rb") do |p|
		begin
		  PTY.spawn( "ruby #{p} #{number}" ) do |stdout, stdin, pid| #arguments?
		    begin
		    	stdout.each { |line| puts line }
		    rescue Errno::EIO
		    end
		  end
		rescue PTY::ChildExited
		  puts "The child process exited!"
		end
	end
#elsif [multiple predictions] stop and match what it predicts vs. the actual next inputs
elsif ARGV[0] == "predict_up" && forward_connections.size >= 2
	input_size = global_ram.partition('/').last.to_i
	prediction_index = backward_connections.index("#{global_ram}") + 1
	prediction = backward_connections[prediction_index]
	Dir.glob("#{home_dir}/#{prediction}") do |p|
		begin
		  PTY.spawn( "ruby #{p} predict_down" ) do |stdout, stdin, pid|
		    begin
		    	stdout.each { |line| puts line }
		    rescue Errno::EIO
		    end
		  end
		rescue PTY::ChildExited
		  puts "The child process exited!"
		end
	end
elsif ARGV[0] == "predict_down" #predict this to happen, read next number of inputs to verify
	#CHANGE THIS -- SHOULD NOT GET NEXT NUMBER HERE, get it in event-fire location instead plz
	File.open("#{home_dir}/ram.txt", 'w') { |f| f.write("#{location}.to_s") }
	Dir.glob("#{home_dir}/c.rb") do |p|
	begin
	  PTY.spawn( "ruby #{p} #{number}" ) do |stdout, stdin, pid| #arguments?
	    begin
	    	stdout.each { |line| puts line }
	    rescue Errno::EIO
	    end
	  end
	rescue PTY::ChildExited
	  puts "The child process exited!"
	end
	end
elsif ARGV[0] == "input"
	sequence_size = (global_ram.partition('/').last.partition('/').first.to_i)
	next_sequence_size = sequence_size + number
	next_sequence_size = 1 if next_sequence_size == 0
	already_created = 0
	#neurons this one is connected to:
	hash = Hash.new
	forward_connections.each do |connection|
		links = []
		connection_size = connection.partition('/').last.partition('/').first.to_i
		if connection_size == next_sequence_size
			File.open("#{home_dir}/#{connection}/<.txt", 'r').each_line { |line| links << line}
		end
		hash['connection'] = links
	end
	indices_hash = Hash.new
	hash.each do |connection, backlinks|
		#link_index = value.index(location)
		#index_hash = { "#{key}" => link_index }
		indices = backlinks.each_index.select{ |i| backlinks[i] == location }
		indices_hash["#{connection}"] = indices
	end
	indices_hash.each do |connection, indices|
		possiblities = hash[connection]
		indices.each do |index|
			if possiblities[(index - 1)] == global_ram #already learned this, go fire it
				already_created = 1
				Dir.glob("#{home_dir}/#{connection}") do |p|
					begin
					  PTY.spawn( "ruby #{p} input" ) do |stdout, stdin, pid|
					    begin
					    	stdout.each { |line| puts line }
					    rescue Errno::EIO
					    end
					  end
					rescue PTY::ChildExited
					  puts "The child process exited!"
					end
				end #dir.glob
			end # if possibilities
		end
	end
	if already_created == 0 #new sequence, learn it
		num = 0 
	 	Dir.glob("#{home_dir}/#{next_sequence_size.to_s}/*").select do |f| 
	 		File.directory?(f)
	 		num = num + 1
	 	end
		Dir.mkdir("#{home_dir}/#{next_sequence_size.to_s}") unless Dir.exists?("#{home_dir}/#{next_sequence_size.to_s}")
		Dir.mkdir("#{home_dir}/#{next_sequence_size.to_s}/#{num.to_s}")
		s = File.open("#{location}/n.rb", 'r') { |f| f.read }
		File.open("#{home_dir}/#{next_sequence_size.to_s}/#{num.to_s}/n.rb", 'w') { |f| f.write(s) }
		File.open("#{home_dir}/#{next_sequence_size.to_s}/#{num.to_s}/>.txt", 'w') { |f| f.write("") }
		File.open("#{home_dir}/#{next_sequence_size.to_s}/#{num.to_s}/<.txt", 'w') { |f| f.write("") }
		File.open("#{location}/>.txt", 'w+') { |f| f.write("#{home_dir}/#{next_sequence_size.to_s}/#{num.to_s}\n") }
		File.open("#{home_dir}/#{next_sequence_size.to_s}/#{num.to_s}/<.txt", 'w+') { |f| f.write("#{global_ram}\n") }
		File.open("#{home_dir}/#{next_sequence_size.to_s}/#{num.to_s}/<.txt", 'w+') { |f| f.write("#{location}\n") }
		#File.open("#{home_dir}/ram.txt", 'w') { |f| f.write() }
	end
else

end #BIG if

#if only one forward connection, go there, repeat until multiple predictions or no more predictions
#check it against input with .include?, if wrong, read input with c.rb to learn



#if multiple forward connections, but one of those forward connections is being activated from above, go there, check it 
#against input with .include?, if wrong, read input with c.rb to learn


# If I already know what I see next - don't remember it in ram, keep building sequence until limit of known is reached
# if a neuron fires and WAS NOT being predicted, that is an event worthy of attention (re-scan input to learn sequence?)
# if a neuron fires and WAS being predicted, that sequence needs to be strengthened in memory
# MAKE all future predictions ( -- sub-conscious-thought -- ) but don't take any ACTION until the # of predictions has been narrowed
# ----- when predictions are narrowed, TAKE ACTION (in this case, scan ahead/self-input?/ the prediction)
# There is a difference between sequential predictions and merely RELATED patterns
# ------ *thought* -- *cliff notes* -- "ram" somewhere? -- 
#backward = File.readlines("#{home_dir}/#{next_num.to_s}/#{concat}/<.txt") if File.exists?("#{home_dir}/#{next_num.to_s}/#{concat}/<.txt")
