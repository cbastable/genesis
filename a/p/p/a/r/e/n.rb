require 'pty'
require 'pathname'
location = "#{File.dirname(__FILE__)}"
local_fname = "#{location}/n.txt"
if File.exists?("#{location}/>.txt") && !File.zero?("#{location}/>.txt") 
	prediction_path = File.open("#{location}/>.txt") {|f| f.readline.rstrip.split(":")[1]}
	puts "PREDICTION PATH: #{prediction_path}"
	prediction = File.open("#{prediction_path}/n.txt") {|f| f.readline }
	File.open("#{Dir.pwd}/c.txt", 'w') do |f| 
		f.write("#{prediction}")
	end
end
input = ARGV[0]
next_char_at = ARGV[1].to_i
next_char = input.to_s[next_char_at]
child_next_char_at = next_char_at + 1
home_dir = Dir.pwd
parent = File.expand_path("..",File.dirname(__FILE__))
current_word = File.basename(File.dirname(__FILE__)).to_s
while parent != home_dir
	current_word = current_word + File.basename(parent).to_s
	parent = File.expand_path("..",parent)
end
current_word = current_word.reverse

if input == current_word
	unless File.exists?("#{location}/n.txt")
		File.open("#{location}/n.txt", 'w') do |f| 
			f.write("#{input}".to_s)
		end
	    puts "\t...learned #{input}"
	    ########## -- functionally equivalent blocks -- DRY plz
		s = []
		File.readlines("#{File.expand_path(location)}/<.txt").each do |line|
			s << line
		end
		sources = []
		s.each do |s|
			b = s.split(":")[1]
			sources << b
		end
		sources.each do |source|
			path = source.gsub("#{home_dir}", ".").rstrip
			s = []
			File.readlines("#{path}/>.txt").each do |line|
				s << line
			end
			text = []
			count = 0
			s.each do |s|
					a = (s.split(":")[0]).to_i 
					b = s.split(":")[1]
					if b.rstrip == File.expand_path(location)
						a = a + 1 
						count = count + 1
					end
					c = a.to_s + ":" + b.to_s
					text << c
			end
			text << "1:#{File.expand_path(location)}\n" if count < 1
			text = text.join("")
			File.open("#{path}/>.txt", 'w') do |f| 
		    	if text.length < 1
		    		f.write("1:#{File.expand_path(location)}\n")
		    	else
		    		f.write(text)
		    	end
			end
		end
		##########
	else
		word = File.open("#{location}/n.txt", 'r') { |f| f.read }
		puts "Computer: #{word}"
	    ##########
		s = []
		File.readlines("#{File.expand_path(location)}/<.txt").each do |line|
			s << line
		end
		sources = []
		s.each do |s|
			b = s.split(":")[1]
			sources << b
		end
		sources.each do |source|
			path = source.gsub("#{home_dir}", ".").rstrip
			s = []
			File.readlines("#{path}/>.txt").each do |line|
				s << line
			end
			text = []
			count = 0
			s.each do |s|
					a = (s.split(":")[0]).to_i 
					b = s.split(":")[1]
					if b.rstrip == File.expand_path(location)
						a = a + 1 
						count = count + 1
					end
					c = a.to_s + ":" + b.to_s
					text << c
			end
			text << "1:#{File.expand_path(location)}\n" if count < 1
			text = text.join("")
			File.open("#{path}/>.txt", 'w') do |f| 
		    	if text.length < 1
		    		f.write("1:#{File.expand_path(location)}\n")
		    	else
		    		f.write(text)
		    	end
			end
		end
		##########
	end
elsif Dir.exists?("#{File.dirname(__FILE__)}/#{next_char}")
	s = []
	File.readlines("#{File.dirname(__FILE__)}/#{next_char}/<.txt").each do |line|
		s << line
	end
	text = []
	s.each do |s|
			a = (s.split(":")[0]).to_i + 1
			b = s.split(":")[1]
			c = a.to_s + ":" + b.to_s
			text << c
	end
	text = text.join("")
	File.open("#{File.dirname(__FILE__)}/#{next_char}/<.txt", 'w') do |f| 
    	f.write(text)
	end
	Dir.glob("#{File.dirname(__FILE__)}/#{next_char}/n.rb") do |p|
		begin
		  PTY.spawn( "ruby #{p} #{input} #{child_next_char_at}" ) do |stdout, stdin, pid|
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
	Dir.mkdir("#{File.dirname(__FILE__)}/#{next_char}")
	s = File.open("#{location}/n.rb", 'r') { |f| f.read }
	File.open("#{File.dirname(__FILE__)}/#{next_char}/n.rb", 'w') do |f| 
		f.write(s)
	end
	File.open("#{File.dirname(__FILE__)}/#{next_char}/>.txt", 'w') do |f| 
		f.write("")
	end
	n = 1
    File.open("#{File.dirname(__FILE__)}/#{next_char}/<.txt", 'w+') do |f| 
    	f.write("#{n}:#{File.expand_path(location)}\n")
    	source = File.expand_path("..",File.dirname(__FILE__))
    	while source != home_dir
    		unless File.expand_path("..",source) == home_dir
    			f.write("#{n}:#{source}\n")
    		else
    			f.write("#{n}:#{source}")
    		end
			source = File.expand_path("..",source)
		end
	end
	#puts "\t...learned new path #{location}/#{next_char}"
    Dir.glob("#{File.dirname(__FILE__)}/#{next_char}/n.rb") do |p|
		begin
		  PTY.spawn( "ruby #{p} #{input} #{child_next_char_at}" ) do |stdout, stdin, pid|
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