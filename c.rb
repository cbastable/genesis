require 'pty'
location = "#{File.dirname(__FILE__)}"
size = 1
pos = 0
feed = ARGV[0]
if feed == "external"
	print "Conrad: "
	input = $stdin.gets.chomp.unpack('B*')
	File.open("#{location}/c.txt", "w") { |f| f.write(input.first)} #.unpack returns array, so .first is just the input?
	curr_char = input[pos][0].to_s
	#make a directory for curr_char if doesn't exist...
	if curr_char == 0.to_s
		if !Dir.exists?("#{location}/#{size}/0")
			Dir.mkdir("#{location}/#{size}") unless Dir.exists?("#{location}/#{size}")
			Dir.mkdir("#{location}/#{size}/0")
			s = File.open("#{location}/n.rb", 'r') { |f| f.read }
			File.open("#{location}/#{size}/0/n.rb", 'w') { |f| f.write(s) }
			File.open("#{location}/#{size}/0/>.txt", 'w') { |f| f.write("") }
			File.open("#{location}/#{size}/0/<.txt", 'w') { |f| f.write("") }
		end
		#make ram for current input/write to ram here
		#go to curr_char, fire neuron
		pos = 1
		File.open("#{location}/pos.txt", 'w') { |f| f.write(pos) }
		File.open("#{location}/ram.txt", 'w') { |f| f.write("#{location}/#{size}/0") }
		Dir.glob("#{location}/#{size}/0/n.rb") do |p|
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
		end
	else
		if !Dir.exists?("#{location}/#{size}/1")
			Dir.mkdir("#{location}/#{size}") unless Dir.exists?("#{location}/#{size}")
			Dir.mkdir("#{location}/#{size}/1")
			s = File.open("#{location}/n.rb", 'r') { |f| f.read }
			File.open("#{location}/#{size}/1/n.rb", 'w') { |f| f.write(s) }
			File.open("#{location}/#{size}/1/>.txt", 'w') { |f| f.write("") }
			File.open("#{location}/#{size}/1/<.txt", 'w') { |f| f.write("") }
		end
		#make ram for current input/write to ram here
		#go to curr_char, fire neuron
		pos = 1
		File.open("#{location}/pos.txt", 'w') { |f| f.write(pos) }
		File.open("#{location}/ram.txt", 'w') { |f| f.write("#{location}/#{size}/1") }
		Dir.glob("#{location}/#{size}/1/n.rb") do |p|
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
		end
	end	#if curr_char == 0
else
	#need smart way to find out where in the input I currently am/was reading from
	pos = File.open("#{location}/pos.txt", 'r') { |f| f.read }
	input = File.open("#{location}/c.txt", 'r') { |f| f.read }
	curr_char = input[pos.to_i].to_s
	substring = input[pos.to_i..(pos.to_i + (feed.to_i - 1))]
	puts "sub: #{substring}"
	if !Dir.exists?("#{location}/#{size}/1")
			Dir.mkdir("#{location}/#{size}") unless Dir.exists?("#{location}/#{size}")
			Dir.mkdir("#{location}/#{size}/1")
			s = File.open("#{location}/n.rb", 'r') { |f| f.read }
			File.open("#{location}/#{size}/1/n.rb", 'w') { |f| f.write(s) }
			File.open("#{location}/#{size}/1/>.txt", 'w') { |f| f.write("") }
			File.open("#{location}/#{size}/1/<.txt", 'w') { |f| f.write("") }
	end
	if substring.length == 1
		new_pos = pos.to_i + 1
		File.open("#{location}/pos.txt", 'w') { |f| f.write(new_pos) }
		Dir.glob("#{location}/#{size}/#{substring}/n.rb") do |p|
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
		end
	else
		puts "big string"
		
	end




end