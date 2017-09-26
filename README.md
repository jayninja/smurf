# smurf
smurf broadcast scanner 

I originally wanted to write this using raw packets to get more into ruby packet generation. Unfortunately nothing was really geared toward sending 1 packet and receiving more than 1 in return. Once I was able to get net-ping modified to do what I wanted, it turned out that net-ping was not thread-safe. 
  
After that I gave up on using an ICMP related library, and did it the lame way. I basically just wrapped /bin/ping, and then parsed/threaded it. 

