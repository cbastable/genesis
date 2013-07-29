require 'pty'
location = "#{File.dirname(__FILE__)}"
if ARGV[0] == "external"
	print "Conrad: "
	input = $stdin.gets.chomp.unpack('B*')
	File.open("#{location}/c.txt", "w") { |f| f.write(input.first)}
	curr_char = input[0][0].to_s
	size = 1
	#make a directory for curr_char if doesn't exist...
	if !Dir.exists?("#{location}/#{size}/#{curr_char}")
		Dir.mkdir("#{location}/#{size}")
		Dir.mkdir("#{location}/#{size}/#{curr_char}")
		s = File.open("#{location}/n.rb", 'r') { |f| f.read }
		File.open("#{location}/#{size}/#{curr_char}/n.rb", 'w') { |f| f.write(s) }
	end
	#go to curr_char, fire neuron
	Dir.glob("#{location}/#{size}/#{curr_char}/n.rb") do |p|
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
else
	string = ARGV[0]
	puts string
end