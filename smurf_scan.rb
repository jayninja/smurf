# smurf_scan.rb by James J
#
# When you exit, hit ctrl+c one time, and it will dump all of the broadcasts found. The best method is to just let it 
# finish, and then check bcast.list
#
# todo: 
#  - implement signal USR1 to show broadcasts
#  - maybe a flag to not show failures?
#  - Figure out how to prevent the dump of text after ctrl+c
#  - flag to specify log file? 


require 'net/ping'
require 'in_threads'
require 'getoptlong'
require 'colorize'

logfile = 'bcast.list'
targets = []
num_threads = 500
@dupes = []  #oh shut up it makes it easier than passing it to eac.

def print_dupes(dupes)
  dupes.each do |dupe|
    puts dupe
  end
end

# how we check each ip
def dup_check(host)
  result = `ping -c 2 -n #{host} 2> /dev/null`
  if result.include?("duplicate")
    result = result.scan(/ceived,(.*)duplicates.*$/)
    result = result.to_s.gsub(/\"/, '\'').gsub(/[\[\]]/, '').gsub(/\'/,'')
    print "Checking #{host.green} #{result.green} \n"
    @dupes.push("#{host} #{result}")
  else 
    print "Checking #{host.red}\n"
  end

end

# Build the list of targets
def gen_ips_a(class_a, targets)
  (1..255).each do |class_b|
    (1..255).each do |class_c|
    targets.push("#{class_a}.#{class_b}.#{class_c}.255")
    targets.push("#{class_a}.#{class_b}.#{class_c}.192")
    targets.push("#{class_a}.#{class_b}.#{class_c}.191")
    targets.push("#{class_a}.#{class_b}.#{class_c}.128")
    targets.push("#{class_a}.#{class_b}.#{class_c}.127")
    targets.push("#{class_a}.#{class_b}.#{class_c}.64")
    targets.push("#{class_a}.#{class_b}.#{class_c}.63")
    targets.push("#{class_a}.#{class_b}.#{class_c}.31")
    targets.push("#{class_a}.#{class_b}.#{class_c}.0")
    end
  end
end

def gen_ips_b(class_b, targets)
  (1..255).each do |class_c|
    targets.push ("#{class_b}.#{class_c}.255")
    targets.push ("#{class_b}.#{class_c}.192")
    targets.push ("#{class_b}.#{class_c}.191")
    targets.push ("#{class_b}.#{class_c}.128")
    targets.push ("#{class_b}.#{class_c}.127")
    targets.push ("#{class_b}.#{class_c}.64")
    targets.push ("#{class_b}.#{class_c}.63")
    targets.push ("#{class_b}.#{class_c}.31")
    targets.push ("#{class_b}.#{class_c}.0")
  end
end

# Trap ^C 
Signal.trap("INT") { 
  sleep 2
  puts "\nShutting down gracefully..."
  puts "Dumping broadcasts found:"
  puts @dupes
  open(logfile, 'w') { |file|
  @dupes.each do |dupe|
    file << "#{dupe}\n"
  end
  }
  exit
}

## parse parameters. 
opt = GetoptLong.new(['-a', GetoptLong::OPTIONAL_ARGUMENT],['-b', GetoptLong::OPTIONAL_ARGUMENT],['--help', GetoptLong::NO_ARGUMENT])

opt.each_option do |name,arg|
   case name
     when '--help'
        puts "usage: -a 211 "
        puts "       -b 211.29"
        exit
     when '-a'
        subnetA = arg
        gen_ips_a(subnetA, targets)
     when '-b'
        subnetB = arg    
        gen_ips_b(subnetB, targets)
   end
end

# Main
targets.in_threads(num_threads).map do |target|
 dup_check(target)
end

open(logfile, 'w') { |file|
  @dupes.each do |dupe|
    file << "#{dupe}\n"
  end
}
