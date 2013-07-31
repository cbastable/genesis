require 'pty'
location = "#{File.dirname(__FILE__)}"
size = 1
if ARGV[0] == "external"
	print "Conrad: "
	input = $stdin.gets.chomp.unpack('B*')
	File.open("#{location}/c.txt", "w") { |f| f.write(input.first)} #.unpack returns array, so .first is just the input?
	curr_char = input[0][0].to_s
	#make a directory for curr_char if doesn't exist...
	if !Dir.exists?("#{location}/#{size}/#{curr_char}")
		Dir.mkdir("#{location}/#{size}")
		Dir.mkdir("#{location}/#{size}/#{curr_char}")
		s = File.open("#{location}/n.rb", 'r') { |f| f.read }
		File.open("#{location}/#{size}/#{curr_char}/n.rb", 'w') { |f| f.write(s) }
	end
	#make ram for current input/write to ram here
	#go to curr_char, fire neuron
	Dir.glob("#{location}/#{size}/#{curr_char}/n.rb") do |p|
		begin
		  PTY.spawn( "ruby #{p} upwards" ) do |stdout, stdin, pid|
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
	#need smart way to find out where in the input I currently am/was reading from
	string = ARGV[0]
	puts string
	input = File.open('#{location}/c.txt', 'r') { |f| f.read }
	input[0] = ""
	File.open("#{location}/c.txt", "w") { |f| f.write(input)}
	curr_char = input[0].to_s
	if !Dir.exists?("#{location}/#{size}/#{curr_char}")
		Dir.mkdir("#{location}/#{size}")
		Dir.mkdir("#{location}/#{size}/#{curr_char}")
		s = File.open("#{location}/n.rb", 'r') { |f| f.read }
		File.open("#{location}/#{size}/#{curr_char}/n.rb", 'w') { |f| f.write(s) }
	end
	Dir.glob("#{location}/#{size}/#{curr_char}/n.rb") do |p|
		begin
		  PTY.spawn( "ruby #{p} upwards" ) do |stdout, stdin, pid|
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


