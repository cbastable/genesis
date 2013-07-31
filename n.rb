require 'pty'
require 'pathname'
location = "#{File.dirname(__FILE__)}"
number = location.partition('/').last.to_i
next_num = number + 1
current = location.partition('/').last.partition('/').last.to_i
parent = File.expand_path("..",File.dirname(__FILE__))
home_dir = Dir.pwd
local_fname = "#{location}/n.txt"

#global ram handle
if File.exists?("#{home_dir}/ram.txt") && ARGV[0] == "upwards"
	#read ram
	b = File.open("#{home_dir}/ram.txt", 'r') { |f| f.read }
	next_num = (b.partition('/').last.partition('/').first.to_i) + 1 #next num represents cumulative sequence size
	#make neuron to represent sequence if doesn't exist
	if !Dir.exists?("#{home_dir}/#{next_num.to_s}/#{current.to_s}")
		Dir.mkdir("#{home_dir}/#{next_num.to_s}")
		Dir.mkdir("#{home_dir}/#{next_num.to_s}/#{current.to_s}")
		s = File.open("#{location}/n.rb", 'r') { |f| f.read }
		File.open("#{home_dir}/#{next_num.to_s}/#{current.to_s}/n.rb", 'w') { |f| f.write(s) }
		File.open("#{home_dir}/#{next_num.to_s}/#{current.to_s}/>.txt", 'w') { |f| f.write("") }
		File.open("#{home_dir}/#{next_num.to_s}/#{current.to_s}/<.txt", 'w') { |f| f.write("") }
	end
	#point from here to next tier
	forward_connections = []
	File.open("#{location}/>.txt", 'r').each_line { |line| forward_connections << line}
	File.open("#{location}/>.txt", 'w+') { |f| f.write("#{home_dir}/#{next_num.to_s}/#{current.to_s}\n") } unless forward_connections.include?("#{home_dir}/#{next_num.to_s}/#{current.to_s}")
	#point from next tier to first sequence & here
	backward_connections = []
	File.open("#{home_dir}/#{next_num.to_s}/#{current.to_s}/<.txt", 'r').each_line { |line| backward_connections << line}
	File.open("#{home_dir}/#{next_num.to_s}/#{current.to_s}/<.txt", 'w+') { |f| f.write("#{b}\n") } unless backward_connections.include?(b)
	File.open("#{home_dir}/#{next_num.to_s}/#{current.to_s}/<.txt", 'w+') { |f| f.write("#{location}\n") } unless backward_connections.include?(location)
	#update ram to this current location
	File.open("#{home_dir}/ram.txt", 'w') { |f| f.write("#{location}.to_s") }
else #this was first item in a sequence - could still soft-predict multiple outcomes?

end

#if only one forward connection, go there, check it against input with .include?, if wrong, read input with c.rb to learn
	Dir.glob("#{home_dir}/c.rb") do |p|
		begin
		  PTY.spawn( "ruby #{p} next" ) do |stdout, stdin, pid| #arguments?
		    begin
		    	stdout.each { |line| puts line }
		    rescue Errno::EIO
		    end
		  end
		rescue PTY::ChildExited
		  puts "The child process exited!"
		end
	end
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
