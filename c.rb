require 'pty'
print "Conrad: "
input = $stdin.gets.chomp
first_char = input[0]
curr_char = 0
next_char_at = curr_char + 1

#location = "#{File.dirname(__FILE__)}"
#local_fname = "#{location}/c.txt"
#unless File.exists?(local_fname)
#	File.open(local_fname, 'w') do |f| 
#		f.write(input)
#	end
#    puts "\t...Success, saved to #{local_fname}"
#else
#	File.open(local_fname, 'w') do |f|
#		f.write(input)
#	end
#	s = File.open(local_fname, 'r') { |f| f.read }
#	puts "\t c.txt: #{s}"
#end

Dir.glob("#{File.dirname(__FILE__)}/#{first_char}/n.rb") do |p|
	begin 
	  PTY.spawn( "ruby #{p} #{input} #{next_char_at}" ) do |stdout, stdin, pid|
	    begin
	    	stdout.each { |line| puts line }
	    rescue Errno::EIO
	    end
	  end
	rescue PTY::ChildExited
	  puts "The child process exited!"
	end
end

#Dir.glob("#{Dir.pwd}/**/*.txt") do |f|
#end
#fork do load "#{name}" end #works

#PTY.spawn(RUBY, '-r', THIS_FILE, '-e', 'hello("PTY", true)') do |output, input, pid|
 # input.write("hello from parent\n")
  #buffer = ""
  #output.readpartial(1024, buffer) until buffer =~ /DONE/
  #buffer.split("\n").each do |line|
   # puts "[parent] output: #{line}"
	#end
#end