#!/usr/bin/env ruby

require 'rubygems'
require 'serialport'

semaphore = Mutex.new

FLOORS = 10

curr = 0

sp = SerialPort.new "/dev/tty.usbmodemfd121", 9600, 8 , 1, SerialPort::NONE

#Serial Connection Resets the Chip.
sleep 1.0

a = Thread.new {
  while true
    #Go to a random floor
    direction = (rand(2) == 0) ? 'u' : 'd'
    floor = rand(FLOORS) + 1
    out = "#{direction}#{floor}"
    semaphore.synchronize {
      puts "Need #{direction} at floor #{floor}"
      sp.print "#{out}\r"
      sp.flush
    }
    sleep (rand(5)+1)
  end
}

while true
  resp = ""
  resp = sp.readline("\n")

  if m = /^(f|o)([0-9]+).*/.match(resp)
    if m[1] == 'f'
      target = m[2].to_i
      semaphore.synchronize {
        puts "going to floor  #{m[2]}"
        sp.print "a#{m[2]}\r"
        sp.flush
      }
    elsif m[1] == 'o'
      semaphore.synchronize {
        (rand(2)+1).times do
          flr = rand(FLOORS)+1
          puts "requesting floor #{flr}"
          sp.print "r#{flr}\r"
          sp.flush
        end
      }
      sleep 2.0
      sp.print "c\r"
    end
  else
    puts resp
    raise
  end
end
