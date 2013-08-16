require 'pty'
require 'pathname'
home_dir = Dir.pwd
location = "#{File.dirname(__FILE__)}"
location = location.gsub("#{home_dir}", ".")
number = location.partition('/').last.partition('/').first.to_i
next_num = number + 1
current = location.partition('/').last.partition('/').last.to_i
parent = File.expand_path("..",File.dirname(__FILE__))
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
elsif ARGV[0] == "new"
	puts "Reading next input, currently at: #{location}"
	File.open("#{home_dir}/ram.txt", 'w') { |f| f.write(location) }
	Dir.glob("#{home_dir}/c.rb") do |p|
		begin
		  PTY.spawn( "ruby #{p} 1" ) do |stdout, stdin, pid| #arguments?
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
	existing_cell = ""
	hash = Hash.new{|h, k| h[k] = []}
	puts "Location: #{location}, forward connections: #{forward_connections}"
	forward_connections.each do |connection|
		links = []
		connection_size = connection.partition('/').first.to_i
		File.open("#{home_dir}/#{connection.gsub("\n", "")}/<.txt", 'r').each_line { |line| links << line}
		hash[connection] << links
	end
	puts "Location: #{location}, Hash: #{hash}"

	catch (:break) do
		hash.each do |connection, indices|
			indices.each do |index| #index is an array of possible targets, with newline chars at end
				fixed_targets = []
				index.each do |target| 
					s = target.gsub("\n", "")
					fixed_targets << s
				end
				puts "Fixed: #{fixed_targets}"
				puts "RAM: #{global_ram}"
				puts "Location: #{location}"
				curr_seq_locator = fixed_targets.index(location)
				ram_seq_locator = fixed_targets.index(global_ram)
				puts "RAM LOCATOR: #{ram_seq_locator}"
				puts "CURRENT LOCATOR: #{curr_seq_locator}"
				if !ram_seq_locator.nil? && !curr_seq_locator.nil? && (curr_seq_locator - ram_seq_locator) == 1
					puts "ALREADY LEARNED THIS! BREAK!"
					already_created = 1
					existing_cell = "#{home_dir}/#{connection.gsub("\n", "")}/n.rb"
					puts "#{home_dir}/#{connection.gsub("\n", "")}/n.rb"
					throw :break if already_created == 1
				end
			end #indices.each
		end #hash.each
	end ##catch

	if already_created == 0 && location != global_ram #new sequence, learn it
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
		File.open("#{home_dir}/#{global_ram}/>.txt", 'a+') { |f| f.write("#{next_sequence_size.to_s}/#{num.to_s}\n") }
		File.open("#{home_dir}/#{location}/>.txt", 'a+') { |f| f.write("#{next_sequence_size.to_s}/#{num.to_s}\n") }
		File.open("#{home_dir}/#{next_sequence_size.to_s}/#{num.to_s}/<.txt", 'a+') { |f| f.write("#{global_ram}\n") }
		File.open("#{home_dir}/#{next_sequence_size.to_s}/#{num.to_s}/<.txt", 'a+') { |f| f.write("#{location}\n") }
		Dir.glob("#{home_dir}/#{next_sequence_size.to_s}/#{num.to_s}/n.rb") do |p|
			begin
			  PTY.spawn( "ruby #{p} new" ) do |stdout, stdin, pid|
			    begin
			    	stdout.each { |line| puts line }
			    rescue Errno::EIO
			    end
			  end
			rescue PTY::ChildExited
			  puts "The child process exited!"
			end
		end
	elsif already_created == 0 && location == global_ram
		Dir.glob("#{location}/n.rb") do |p|
		begin
		  PTY.spawn( "ruby #{p} new" ) do |stdout, stdin, pid| #arguments?
		    begin
		    	stdout.each { |line| puts line }
		    rescue Errno::EIO
		    end
		  end
		rescue PTY::ChildExited
		  puts "The child process exited!"
		end
		end	
	else
		Dir.glob(existing_cell) do |p|
			begin
			  PTY.spawn( "ruby #{p} new" ) do |stdout, stdin, pid|
			    begin
			    	stdout.each { |line| puts line }
			    rescue Errno::EIO
			    end
			  end
			rescue PTY::ChildExited
			  puts "The child process exited!"
			end
		end #dir.glob
	end #if already created
else
	puts "else"
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
